#!/usr/bin/env zsh

_todos_cli_command() {
  if command -v td >/dev/null 2>&1; then
    print -r -- "td"
    return 0
  fi

  print -u2 "Todoist CLI command 'td' not found on PATH"
  return 1
}

_todos_normalize_project() {
  local project="$1"
  project="${project#\#}"
  print -r -- "$project"
}

_todos_default_project() {
  local project="${TODO_DEFAULT_PROJECT:-#Work}"
  _todos_normalize_project "$project"
}

_todo_usage() {
  print -u2 "usage: todo <command> [options]"
  print -u2 "commands: add, list, complete, login"
}

_todo_login() {
  local cmd=""

  cmd="$(_todos_cli_command)" || return 1
  "$cmd" auth login "$@"
}

_todo_usage_add() {
  print -u2 "usage: todo add [--project <project>] [--due <natural language due date>] [--parent <task name>] <task>"
  print -u2 "usage: todo add child [--project <project>] [--parent <task name>]"
  print -u2 "usage: todo add children [--project <project>]"
}

_todo_usage_list() {
  print -u2 "usage: todo list [--project <project>] [--today] [--all]"
}

_todo_usage_complete() {
  print -u2 "usage: todo complete [--project <project>] [--today] [--all]"
}

_todo_task_list_json() {
  local project="$1"
  local include_all="$2"
  local cmd=""
  local -a args

  cmd="$(_todos_cli_command)" || return 1
  args=(task list --json --all)

  if (( ! include_all )); then
    args+=(--project "$project")
  fi

  "$cmd" "${args[@]}"
}

_todo_task_selection_rows() {
  python3 -c '
import json
import os
import sys

payload = json.load(sys.stdin)
items = payload.get("results", []) if isinstance(payload, dict) else payload

print("__CANCEL__\t[Cancel]")

USE_COLOR = sys.stdout.isatty() and not os.environ.get("NO_COLOR")
DUE_COLOR = "\033[92m"
RESET_COLOR = "\033[0m"
LEVEL_COLORS = [
  "\033[38;5;153m",
  "\033[38;5;151m",
  "\033[38;5;223m",
  "\033[38;5;181m",
  "\033[38;5;186m",
]

def clean(value):
  return str(value).replace("\t", " ").replace("\n", " ")

item_map = {}
children = {}
ordered_ids = []
for item in items:
  item_id = item.get("id")
  if not item_id:
    continue
  item_id = str(item_id)
  item_map[item_id] = item
  ordered_ids.append(item_id)
  parent_id = item.get("parentId")
  parent_key = str(parent_id) if parent_id else ""
  children.setdefault(parent_key, []).append(item_id)

def breadcrumb(item_id):
  parts = []
  seen_ids = set()
  current_id = item_id
  while current_id and current_id not in seen_ids:
    seen_ids.add(current_id)
    current = item_map.get(current_id)
    if not current:
      break
    parts.append((current.get("content") or "").strip())
    parent_id = current.get("parentId")
    current_id = str(parent_id) if parent_id else ""
  parts = [part for part in reversed(parts) if part]
  return " > ".join(parts)

def emit(item_id):
  item = item_map[item_id]
  due_data = item.get("due") or {}
  due = due_data.get("string") or due_data.get("date") or ""
  label = breadcrumb(item_id)
  if due:
    label = f"{label} ({due})"
  print("\t".join([clean(item_id), clean(label)]))

def walk(item_id, seen_ids):
  if item_id in seen_ids:
    return
  seen_ids.add(item_id)
  emit(item_id)
  for child_id in children.get(item_id, []):
    walk(child_id, seen_ids)

seen_ids = set()
for item_id in ordered_ids:
  item = item_map[item_id]
  parent_id = item.get("parentId")
  parent_key = str(parent_id) if parent_id else ""
  if parent_key and parent_key in item_map:
    continue
  walk(item_id, seen_ids)

for item_id in ordered_ids:
  if item_id not in seen_ids:
    walk(item_id, seen_ids)
'
}

_todo_select_parent() {
  local project="$1"
  local include_all="${2:-0}"
  local selection=""

  if ! command -v fzf >/dev/null 2>&1; then
    print -u2 "fzf not found on PATH"
    print -u2 "install it with: brew install fzf"
    return 1
  fi

  selection=$(_todo_task_list_json "$project" "$include_all" | _todo_task_selection_rows | fzf --delimiter=$'\t' --with-nth=2 --prompt='todo parent > ' --height=40% --reverse) || return $?

  if [[ -z "$selection" ]]; then
    return 1
  fi

  if [[ "${selection%%$'\t'*}" == "__CANCEL__" ]]; then
    return 0
  fi

  print -r -- "${selection%%$'\t'*}"
}

_todo_resolve_parent() {
  local parent_ref="$1"
  local project="$2"
  local matches=""
  local match_count=0

  if [[ -z "$parent_ref" ]]; then
    return 1
  fi

  if [[ "$parent_ref" == id:* ]]; then
    print -r -- "$parent_ref"
    return 0
  fi

  matches=$(_todo_task_list_json "$project" 0 | python3 -c '
import json
import sys

parent_ref = sys.argv[1]
payload = json.load(sys.stdin)
items = payload.get("results", []) if isinstance(payload, dict) else payload
exact = []
partial = []
needle = parent_ref.casefold()
for item in items:
    item_id = item.get("id", "")
    content = (item.get("content") or "").strip()
    if not item_id or not content:
        continue
    row = "\t".join([
        str(item_id).replace("\t", " ").replace("\n", " "),
        content.replace("\t", " ").replace("\n", " "),
    ])
    if content.casefold() == needle:
        exact.append(row)
    elif needle in content.casefold():
        partial.append(row)

rows = exact if exact else partial
for row in rows:
    print(row)
' "$parent_ref") || return 1

  if [[ -z "$matches" ]]; then
    print -u2 "todo add: parent task '$parent_ref' not found in project '$project'"
    return 1
  fi

  match_count=$(printf '%s\n' "$matches" | wc -l | tr -d ' ')

  if [[ "$match_count" == "1" ]]; then
    print -r -- "${matches%%$'\t'*}"
    return 0
  fi

  if ! command -v fzf >/dev/null 2>&1; then
    print -u2 "todo add: multiple parent tasks matched '$parent_ref'; install fzf or use a more specific name"
    return 1
  fi

  local selection=""
  selection=$(printf '%s\n' "$matches" | fzf --delimiter=$'\t' --with-nth=2 --prompt='todo parent match > ' --height=40% --reverse) || return $?

  if [[ -z "$selection" ]]; then
    return 1
  fi

  print -r -- "${selection%%$'\t'*}"
}

_todo_add_children() {
  local project="$1"
  local parent_ref="$2"
  local parent_id=""
  local cmd=""
  local child_task=""
  local created=0

  cmd="$(_todos_cli_command)" || return 1

  if [[ -n "$parent_ref" ]]; then
    parent_id="$(_todo_resolve_parent "$parent_ref" "$project")" || return 1
  else
    parent_id="$(_todo_select_parent "$project" 0)" || return 1
    if [[ -z "$parent_id" ]]; then
      return 0
    fi
  fi

  while true; do
    print -n "child> "
    IFS= read -r child_task || break

    if [[ -z "$child_task" ]]; then
      break
    fi

    "$cmd" task add "$child_task" --project "$project" --parent "$parent_id" || return $?
    created=1
  done

  if (( ! created )); then
    print -u2 "todo add children: no child tasks added"
  fi
}

_todo_add() {
  local project="$(_todos_default_project)"
  local due=""
  local parent_ref=""
  local parent_id=""
  local cmd=""
  local task=""
  local -a positional
  local -a args

  while (( $# > 0 )); do
    case "$1" in
      --project)
        if (( $# < 2 )); then
          print -u2 "todo add: --project requires a value"
          return 2
        fi
        project="$(_todos_normalize_project "$2")"
        shift 2
        ;;
      --due)
        if (( $# < 2 )); then
          print -u2 "todo add: --due requires a value"
          return 2
        fi
        due="$2"
        shift 2
        ;;
      --parent)
        if (( $# < 2 )); then
          print -u2 "todo add: --parent requires a value"
          return 2
        fi
        parent_ref="$2"
        shift 2
        ;;
      -h|--help)
        _todo_usage_add
        return 0
        ;;
      --)
        shift
        while (( $# > 0 )); do
          positional+=("$1")
          shift
        done
        ;;
      -*)
        print -u2 "todo add: unknown option '$1'"
        _todo_usage_add
        return 2
        ;;
      *)
        positional+=("$1")
        shift
        ;;
    esac
  done

  if (( ${#positional[@]} == 0 )); then
    _todo_usage_add
    return 2
  fi

  if (( ${#positional[@]} == 1 )) && [[ "${positional[1]}" == "child" || "${positional[1]}" == "children" ]]; then
    if [[ -n "$due" ]]; then
      print -u2 "todo add ${positional[1]}: --due is not supported"
      return 2
    fi

    _todo_add_children "$project" "$parent_ref"
    return $?
  fi

  cmd="$(_todos_cli_command)" || return 1
  task="${(j: :)positional}"
  args=(task add "$task" --project "$project")

  if [[ -n "$due" ]]; then
    args+=(--due "$due")
  fi

  if [[ -n "$parent_ref" ]]; then
    parent_id="$(_todo_resolve_parent "$parent_ref" "$project")" || return 1
    args+=(--parent "$parent_id")
  fi

  "$cmd" "${args[@]}"
}

_todo_list() {
  local project="$(_todos_default_project)"
  local only_today=0
  local include_all=0
  local cmd=""
  local -a args

  while (( $# > 0 )); do
    case "$1" in
      --project)
        if (( $# < 2 )); then
          print -u2 "todo list: --project requires a value"
          return 2
        fi
        project="$(_todos_normalize_project "$2")"
        shift 2
        ;;
      --today)
        only_today=1
        shift
        ;;
      --all)
        include_all=1
        shift
        ;;
      -h|--help)
        _todo_usage_list
        return 0
        ;;
      -*)
        print -u2 "todo list: unknown option '$1'"
        _todo_usage_list
        return 2
        ;;
      *)
        print -u2 "todo list: unexpected argument '$1'"
        _todo_usage_list
        return 2
        ;;
    esac
  done

  cmd="$(_todos_cli_command)" || return 1
  args=(task list --json)

  if (( ! include_all )); then
    args+=(--project "$project")
  fi

  if (( only_today )); then
    args+=(--due today)
  fi

  "$cmd" "${args[@]}" | python3 -c '
import json
import os
import sys

payload = json.load(sys.stdin)
items = payload.get("results", []) if isinstance(payload, dict) else payload

USE_COLOR = sys.stdout.isatty() and not os.environ.get("NO_COLOR")
DUE_COLOR = "\033[92m"
RESET_COLOR = "\033[0m"
LEVEL_COLORS = [
  "\033[38;5;153m",
  "\033[38;5;151m",
  "\033[38;5;223m",
  "\033[38;5;181m",
  "\033[38;5;186m",
]

item_map = {}
children = {}
ordered_ids = []
for item in items:
  item_id = item.get("id")
  if not item_id:
    continue
  item_id = str(item_id)
  item_map[item_id] = item
  ordered_ids.append(item_id)
  parent_id = item.get("parentId")
  parent_key = str(parent_id) if parent_id else ""
  children.setdefault(parent_key, []).append(item_id)

def line_for(item_id, depth):
  item = item_map[item_id]
  content = (item.get("content") or "").strip()
  due_data = item.get("due") or {}
  due = due_data.get("string") or due_data.get("date") or ""
  indent = "  " * depth
  content_label = content
  if USE_COLOR:
    content_color = LEVEL_COLORS[depth % len(LEVEL_COLORS)]
    content_label = f"{content_color}{content}{RESET_COLOR}"
  if due:
    due_label = f"({due})"
    if USE_COLOR:
      due_label = f"{DUE_COLOR}{due_label}{RESET_COLOR}"
    return f"{indent}{content_label} {due_label}"
  return f"{indent}{content_label}"

def walk(item_id, depth, seen_ids):
  if item_id in seen_ids:
    return
  seen_ids.add(item_id)
  print(line_for(item_id, depth))
  for child_id in children.get(item_id, []):
    walk(child_id, depth + 1, seen_ids)

seen_ids = set()
for item_id in ordered_ids:
  item = item_map[item_id]
  parent_id = item.get("parentId")
  parent_key = str(parent_id) if parent_id else ""
  if parent_key and parent_key in item_map:
    continue
  walk(item_id, 0, seen_ids)

for item_id in ordered_ids:
  if item_id not in seen_ids:
    walk(item_id, 0, seen_ids)
'
}

_todo_complete() {
  local project="$(_todos_default_project)"
  local only_today=0
  local include_all=0
  local cmd=""
  local selection=""
  local item_id=""
  local completed=0
  local -a list_args

  while (( $# > 0 )); do
    case "$1" in
      --project)
        if (( $# < 2 )); then
          print -u2 "todo complete: --project requires a value"
          return 2
        fi
        project="$(_todos_normalize_project "$2")"
        shift 2
        ;;
      --today)
        only_today=1
        shift
        ;;
      --all)
        include_all=1
        shift
        ;;
      -h|--help)
        _todo_usage_complete
        return 0
        ;;
      -*)
        print -u2 "todo complete: unknown option '$1'"
        _todo_usage_complete
        return 2
        ;;
      *)
        print -u2 "todo complete: unexpected argument '$1'"
        _todo_usage_complete
        return 2
        ;;
    esac
  done

  cmd="$(_todos_cli_command)" || return 1

  if ! command -v fzf >/dev/null 2>&1; then
    print -u2 "fzf not found on PATH"
    print -u2 "install it with: brew install fzf"
    return 1
  fi

  list_args=(task list --json)

  if (( ! include_all )); then
    list_args+=(--project "$project")
  fi

  if (( only_today )); then
    list_args+=(--due today)
  fi

  while true; do
    selection=$("$cmd" "${list_args[@]}" | _todo_task_selection_rows | fzf --delimiter=$'\t' --with-nth=2 --prompt='todo complete > ' --height=40% --reverse)

    if [[ -z "$selection" ]]; then
      return 0
    fi

    item_id="${selection%%$'\t'*}"
    if [[ "$item_id" == "__CANCEL__" ]]; then
      return 0
    fi
    "$cmd" task complete "$item_id" || return $?
    completed=1
  done
}

todo() {
  local command="$1"

  if [[ -z "$command" ]]; then
    _todo_usage
    return 2
  fi

  shift

  case "$command" in
    add)
      _todo_add "$@"
      ;;
    list)
      _todo_list "$@"
      ;;
    complete)
      _todo_complete "$@"
      ;;
    login)
      _todo_login "$@"
      ;;
    -h|--help|help)
      _todo_usage
      ;;
    *)
      print -u2 "todo: unknown command '$command'"
      _todo_usage
      return 2
      ;;
  esac
}