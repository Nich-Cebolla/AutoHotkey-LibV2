
; https://github.com/Lexikos/CLR.ahk
#include <clr>

/**
 * @description - Executes PowerShell code and returns the output as string.
 * This code was obtained from {@link https://www.autohotkey.com/boards/viewtopic.php?style=19&p=288852#p288852 user tmplinshi}.
 */
RunPsCode(code) {
    return CLR_CompileCS('
        (
        using System.Text;
        using System.Collections.ObjectModel;
        using System.Management.Automation;
        using System.Management.Automation.Runspaces;

        public class ps
        {
        	public string RunScript(string scriptText)
        	{
        		Runspace runspace = RunspaceFactory.CreateRunspace();
        		runspace.Open();

        		Pipeline pipeline = runspace.CreatePipeline();
        		pipeline.Commands.AddScript(scriptText);
        		pipeline.Commands.Add("Out-String");

        		Collection<PSObject> results = pipeline.Invoke();

        		runspace.Close();
        		return results[0].ToString();

        		/*
        		StringBuilder stringBuilder = new StringBuilder();
        		foreach (PSObject obj in results)
        		{
        			stringBuilder.AppendLine(obj.ToString());
        		}

        		return stringBuilder.ToString();
        		*/
        	}
        }
        )'
      , 'System.Core.dll | C:\Windows\Microsoft.NET\assembly\GAC_MSIL\System.Management.Automation\v4.0_3.0.0.0__31bf3856ad364e35\System.Management.Automation.dll'
    ).CreateInstance('ps').RunScript(code)
}
