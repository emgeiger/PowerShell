Add-Type -AssemblyName System
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization.Charting

# $charting = New-Object System.Windows.Forms
$componentModel = [System.ComponentModel]
$data = [System.Data]
$drawing = [System.Drawing]
$form = [System.Windows.Forms]
$generic = [System.Collections.Generic]
$interopServices = [System.Runtime.InteropServices]
$io = [System.IO]
$ports = [System.IO.Ports]
$Linq = [System.Linq]
$tasks = [System.Threading.Tasks]
$text = [System.Text]

# $chart = [System.Windows.Forms]

$C_Sharp = @" 
[DllImport("user32.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)] 
"@

# $ShowWindowAsync = Add-Type -MemberDefinition $C_Sharp

Add-Type -AssemblyName $componentModel
Add-Type -AssemblyName $data
Add-Type -AssemblyName $drawing
Add-Type -AssemblyName $generic
Add-Type -AssemblyName $interopServices
Add-Type -AssemblyName $io
Add-Type -AssemblyName $ports
Add-Type -AssemblyName $Linq
Add-Type -AssemblyName $tasks
Add-Type -AssemblyName $text

public class ClickVars
{
    public enum MouseEventFlags
    {
        LEFTDOWN   = 0x00000002,
        LEFTUP     = 0x00000004,
        RIGHTDOWN  = 0x00000008,
        RIGHTUP    = 0x00000010,
    }

    [DllImport("user32.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
    public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint cButtons, uint dwExtraInfo);

    void click()
    {
        mouse_event (LEFTDOWN | LEFTUP, 0, 0, 0, 0);
    }
}