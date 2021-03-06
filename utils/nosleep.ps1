#Copyright (c) 2018 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

# based on of utility to prevent workstations from going to sleep (during long running processes) from the article [Give your computer sleep apnea - Don't let it go](https://www.codeproject.com/KB/winsdk/No_Sleep/Prevent_Sleep.zip)
# see also: https://docs.microsoft.com/en-us/windows/desktop/api/winbase/nf-winbase-powercreaterequest
# https://github.com/dahall/Vanara/blob/master/PInvoke/Kernel32/CorrelationReport.md
# https://stackoverflow.com/questions/629240/prevent-windows-from-going-into-sleep-when-my-program-is-running
$guid = [guid]::NewGuid()


Add-Type -Name 'SleepControl' -Namespace 'Util' -MemberDefinition @'

[DllImport("kernel32", CharSet = CharSet.Ansi, ExactSpelling = true, SetLastError = true)]
public static extern long SetThreadExecutionState(long esflags);
'@

# TODO: randomize the namespace
$helper_type_namespace = ('Util_{0}' -f ($guid -replace '-',''))
$helper_type_name = 'SleepControl'

# Add-Type -Name $helper_type_name -Namespace $helper_type_namespace -MemberDefinition @" ... "@

[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$f = New-Object System.Windows.Forms.Form
$f.SuspendLayout()
$f.Size = New-Object System.Drawing.Size (132,105)
$s = New-Object System.Windows.Forms.Button
$s.Text = 'No Sleep'
# https://msdn.microsoft.com/en-us/library/windows/desktop/aa373208(v=vs.85).aspx

$ES_SYSTEM_REQUIRED = 0x00000001
$ES_DISPLAY_REQUIRED = 0x00000002
$ES_CONTINUOUS = 0x80000000 # -2147483648
function SetThreadExecutionState {
  param(
    [long]$State
  )
  write-debug ('Sending {0}' -f $state )
  # https://www.pinvoke.net/default.aspx/kernel32.setthreadexecutionstate
  [Util.SleepControl]::SetThreadExecutionState($State)
}

$s.Location = New-Object System.Drawing.Point (10,12)
$s.Size = New-Object System.Drawing.Size (100,22)

$s.add_Click({
  $f.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
  SetThreadExecutionState -state ( $ES_SYSTEM_REQUIRED -bor $ES_CONTINUOUS -bor $ES_DISPLAY_REQUIRED )
  # -2147483645
})
$f.add_Closing({ SetThreadExecutionState -state ( $ES_CONTINUOUS) })

$f.Controls.AddRange(@($s))
$f.ResumeLayout($false)
# TODO: start minimized in he taskbar, indicate the app is running
[void]$f.ShowDialog()
<#
# determine user input| idle state
# origin: http://forum.oszone.net/thread-335867.html
Add-Type @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace PInvoke.Win32 {

  public static class UserInput {

    [DllImport("user32.dll", SetLastError=false)]
    private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    [StructLayout(LayoutKind.Sequential)]
    private struct LASTINPUTINFO {
      public uint cbSize;
      public int dwTime;
    }

    public static DateTime LastInput {
      get {
        DateTime bootTime = DateTime.UtcNow.AddMilliseconds(-Environment.TickCount);
        DateTime lastInput = bootTime.AddMilliseconds(LastInputTicks);
        return lastInput;
      }
    }

    public static TimeSpan IdleTime {
      get {
        return DateTime.UtcNow.Subtract(LastInput);
      }
    }

    public static int LastInputTicks {
      get {
        LASTINPUTINFO lii = new LASTINPUTINFO();
        lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
        GetLastInputInfo(ref lii);
        return lii.dwTime;
      }
    }
  }
}
"@

write-output ("Last input: {0}" -f ([PInvoke.Win32.UserInput]::LastInput))
write-output ("Idle for: {0}" -f ([PInvoke.Win32.UserInput]::IdleTime))

#>
