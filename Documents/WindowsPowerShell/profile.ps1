if ($host.Name -eq 'ConsoleHost')
{
    Set-Alias c clear

	function say([string]$text) {
		Add-Type -AssemblyName System.speech; 
		$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer; 
		$speak.SelectVoice('Microsoft Zira Desktop')
		$speak.Speak($text)
	}

	function repo([string]$repoName) {
		cd "$HOME\Repos\$repoName"
	}

	function tail([string]$fileName, [int]$lines=10) {
		Get-Content $fileName | Select-Object -Last $lines
	}
}
