# Credits to: 
# https://github.com/originell/jpype/appveyor/runTestsuite.ps1
#
function xslt_transform($xml, $xsl, $output)
{
	trap [Exception]
	{
	    Write-Host $_.Exception
	}
	
	$xslt = New-Object System.Xml.Xsl.XslCompiledTransform
	$xslt.Load($xsl)
	$xslt.Transform($xml, $output)
}

function upload($file) {
    trap [Exception]
    {
        Write-Host $_.Exception
    }

    $wc = New-Object 'System.Net.WebClient'
    $wc.UploadFile("https://ci.appveyor.com/api/testresults/xunit/$($env:APPVEYOR_JOB_ID)", $file)
}

function run {
    Write-Host $env:APPVEYOR_BUILD_FOLDER

    cd $env:APPVEYOR_BUILD_FOLDER
    $stylesheet =  "transform_xunit_to_appveyor.xsl"
    $input = "nosetests.xml"
    $output = "transformed.xml"
    
    #nosetests  --all-modules --with-xunit pywinauto/unittests/testall.py
    $utdir = "pywinauto\unittests"
    $coveropt = "--with-coverage --cover-html --cover-html-dir=Coverage_report --cover-package=pywinauto"
    nosetests --exclude=testall --with-xunit $coveropt $utdir
    $success = $?
    Write-Host "result code of nosetests:" $success

    xslt_transform $input $stylesheet $output

    upload $output
    
    # return exit code of testsuite
    if ( -not $success) {
        throw "testsuite not successful"
    }
}

run
