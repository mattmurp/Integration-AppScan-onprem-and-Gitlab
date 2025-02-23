write-host "======== Step: Converting ASE SAST XML to Gitlab JSON ========"
# Unzip scan_report.zip and open the folder
Expand-Archive .\scan_report.zip
cd .\scan_report\
# Preparing to convert from ASE XML to Gitlab Json format
$header="{`"version`":`"15.0.4`",`"vulnerabilities`":[";
echo $header | Out-File -Append -NonewLine .\gl-sast-report.json;
# Load list of ase xml files
$files=$(Get-Item -Path *.xml);
# For each XML file extract vulnerabilities items and add into gl-dast-report.json
ForEach ($file in $files){
  [XML]$xml = Get-Content $file;
    # If there is just 1 vulnerability item in the XML file
    if ($xml.'xml-report'.'issue-group'.item.count -eq 1){
      $ErrorActionPreference = 'SilentlyContinue';
      $nameMessageDescriptionCode=$xml.'xml-report'.'issue-group'.item.'issue-type'.ref;
      $nameMessageDescriptionValue=($xml.'xml-report'.'issue-type-group'.item | Where-Object {$_.id -eq $xml.'xml-report'.'issue-group'.item.'issue-type'.ref}).name.Replace('"','');
      $nameMessageDescriptionText1=($xml.'xml-report'.'cause-group'.item | where-object {$_.id -eq ($xml.'xml-report'.'issue-type-group'.item | where-object {$_.id -eq $xml.'xml-report'.'issue-group'.item.'issue-type'.ref}).causes.ref}).'#text';
      $nameMessageDescriptionText2=($xml.'xml-report'.'cause-group'.item | where-object {$_.id -eq ($xml.'xml-report'.'issue-type-group'.item | where-object {$_.id -eq $xml.'xml-report'.'issue-group'.item.'issue-type'.ref}).causes.ref}).'#text';
      $nameMessageDescriptionText="$nameMessageDescriptionText1. $nameMessageDescriptionText2."
      $callingMethod=$xml.'xml-report'.'issue-group'.item.'attributes-group'.attribute[25].value.Replace('\','\\')
      $sourceFile=$xml.'xml-report'.'issue-group'.item.'attributes-group'.attribute[46].value.Replace('\','\\')
      $fileLineLocation=$xml.'xml-report'.'issue-group'.item.'attributes-group'.attribute[5].value.Replace('\','\\')
      $sourceLine=$xml.'xml-report'.'issue-group'.item.'attributes-group'.attribute[37].value
      $sevValue=$xml.'xml-report'.'issue-group'.item.'attributes-group'.attribute[9].value.Replace('Information','Info').Replace('Use CVSS','Unknown');
      $cveValue="$(Get-Random)"+"appscanid"+"$($xml.'xml-report'.'issue-group'.item.'attributes-group'.attribute[4].value)";
      $appscanId=$xml.'xml-report'.'issue-group'.item.'attributes-group'.attribute[4].value;
      $idIssues="{`"id`":`"$([guid]::NewGuid().Guid)`",`"category`":`"sast`",`"name`":`"$nameMessageDescriptionCode`",`"message`":`"$nameMessageDescriptionValue in $fileLineLocation`",`"description`":`"$nameMessageDescriptionText`",`"cve`":`"$cveValue`",`"severity`":`"$sevValue`",`"confidence`": `"Unknown`",`"scanner`":{`"id`":`"appscan_source`",`"name`":`"HCL AppScan Source`"},`"location`":{`"file`":`" $sourceFile`",`"start_line`":$sourceLine,`"class`":`"$callingMethod`",`"method`":`"Appscan_Report_Id_$appscanId`"},`"identifiers`":[{`"type`":`"$nameMessageDescriptionCode`",`"name`":`"ASE: $nameMessageDescriptionCode`",`"value`":`"appscan_source`",`"url`":`"https://$aseHostname`:9443/ase/api/issuetypes/howtofix?issueTypeId=wf-security-check-$nameMessageDescriptionCode`"},{`"type`":`"cwe`",`"name`":`"CWE-699`",`"value`":`"699`",`"url`":`"https://cwe.mitre.org/data/definitions/699.html`"}]}," | Out-File -Append -NonewLine .\gl-sast-report.json;
    }
    else{
      $countIssues=$xml.'xml-report'.'issue-group'.item.count-1
      [array]$totalIssues=@(0..$countIssues);
      ForEach ($i in $totalIssues) {
        $ErrorActionPreference = 'SilentlyContinue';
        $nameMessageDescriptionCode=$xml.'xml-report'.'issue-group'.item[$i].'issue-type'.ref;
        $nameMessageDescriptionValue=($xml.'xml-report'.'issue-type-group'.item | Where-Object {$_.id -eq $xml.'xml-report'.'issue-group'.item[$i].'issue-type'.ref}).name.Replace('"','');
        $nameMessageDescriptionText1=($xml.'xml-report'.'cause-group'.item | where-object {$_.id -eq ($xml.'xml-report'.'issue-type-group'.item | where-object {$_.id -eq $xml.'xml-report'.'issue-group'.item.'issue-type'.ref}).causes.ref}).'#text';
        $nameMessageDescriptionText2=($xml.'xml-report'.'cause-group'.item | where-object {$_.id -eq ($xml.'xml-report'.'issue-type-group'.item | where-object {$_.id -eq $xml.'xml-report'.'issue-group'.item[$i].'issue-type'.ref}).causes.ref}).'#text';
        $nameMessageDescriptionText="$nameMessageDescriptionText1 $nameMessageDescriptionText2"
        $callingMethod=$xml.'xml-report'.'issue-group'.item[$i].'attributes-group'.attribute[25].value.Replace('\','\\')
        $sourceFile=$xml.'xml-report'.'issue-group'.item[$i].'attributes-group'.attribute[46].value.Replace('\','\\')
        $fileLineLocation=$xml.'xml-report'.'issue-group'.item[$i].'attributes-group'.attribute[5].value.Replace('\','\\')
        $sourceLine=$xml.'xml-report'.'issue-group'.item[$i].'attributes-group'.attribute[37].value
        $sevValue=$xml.'xml-report'.'issue-group'.item[$i].'attributes-group'.attribute[9].value.Replace('Information','Info').Replace('Use CVSS','Unknown');
        $cveValue="$(Get-Random)"+"appscanid"+"$($xml.'xml-report'.'issue-group'.item[$i].'attributes-group'.attribute[4].value)";
        $appscanId=$xml.'xml-report'.'issue-group'.item[$i].'attributes-group'.attribute[4].value;
        $idIssues="{`"id`":`"$([guid]::NewGuid().Guid)`",`"category`":`"sast`",`"name`":`"$nameMessageDescriptionCode`",`"message`":`"$nameMessageDescriptionValue in $fileLineLocation`",`"description`":`"$nameMessageDescriptionText`",`"cve`":`"$cveValue`",`"severity`":`"$sevValue`",`"confidence`": `"Unknown`",`"scanner`":{`"id`":`"appscan_source`",`"name`":`"HCL AppScan Source`"},`"location`":{`"file`":`" $sourceFile`",`"start_line`":$sourceLine,`"class`":`"$callingMethod`",`"method`":`"Appscan_Report_Id_$appscanId`"},`"identifiers`":[{`"type`":`"$nameMessageDescriptionCode`",`"name`":`"ASE: $nameMessageDescriptionCode`",`"value`":`"appscan_source`",`"url`":`"https://$aseHostname`:9443/ase/api/issuetypes/howtofix?issueTypeId=wf-security-check-$nameMessageDescriptionCode`"},{`"type`":`"cwe`",`"name`":`"CWE-699`",`"value`":`"699`",`"url`":`"https://cwe.mitre.org/data/definitions/699.html`"}]}," | Out-File -Append -NonewLine .\gl-sast-report.json;
      }
    }
  }
# Remove the last comma
$sastReport = Get-Content .\gl-sast-report.json
$sastReport = $sastReport.SubString(0,$sastReport.Length-1) | Out-File -NonewLine .\gl-sast-report.json
# Extract date from ASE XML and add into gl-dast-report.json
$reportDateTime=$xml.'xml-report'.layout.'report-date-and-time'.Replace('/','-').Replace(' ','T')
# Finish gl-dast-report.json
$footer="],`"scan`":{`"analyzer`":{`"id`":`"appscan_source`",`"name`":`"appscan_source`",`"vendor`":{`"name`":`"HCL`"},`"version`":`"10.0.7`"},`"scanner`":{`"id`":`"sast`",`"name`":`"Find Security Issues`",`"url`":`"https://help.hcltechsw.com/appscan/Source/10.0.7/topics/home.html`",`"vendor`":{`"name`":`"HCL`"},`"version`":`"10.0.7`"},`"type`":`"sast`",`"start_time`":`"$reportDateTime`",`"end_time`":`"$reportDateTime`",`"status`":`"success`"}}" | Out-File -Append -NonewLine .\gl-sast-report.json
write-host "AppScan Enterprise XML result converted to gl-sast-report.json."
# Back to root folderr
cd..
