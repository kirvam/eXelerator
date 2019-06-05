
my $sample = '"/subscriptions/fd89dff0-d96f-4bb5-a96b-e42d76c96492/resourceGroups/EAG-TST/providers/Microsoft.Compute/virtualMachines/EAG-TST-instigator","","Canonical","{  ""ImageType"": ""Canonical"",  ""ServiceType"": ""Standard_B1s"",  ""VMName"": null,  ""VMProperties"": null,  ""VCPUs"": 1,  ""UsageType"": ""ComputeHR""}","""ORG"": ""EAG"",""TYPE"": ""TST""","","Unassigned","","100 Hours","EAG-TST","False"';

my $sampleX = '"/subscriptions/EAG-TST/ms.co/providers/EAG-TST-instigator","","Canonical","""ORG"": ""EAG"",""TYPE"": ""TST""","","Unassigned","","100 Hours","EAG-TST","False"';

###
# pmphaigh@sovgov.onmicrosoft.com,PMPHAIGH,,0,fd89dff0-d96f-4bb5-a96b-e42d76c96492,EAG-TST,5/31/2019,5,31,2019,Bandwidth - Data Transfer In - US Gov Zone 1,3a9d164b-d3c1-4350-9945-fa8056700299,Bandwidth,,US Gov Zone 1,Data Transfer In,0.024354,0,0,usgovvirginia,Microsoft.Compute,/subscriptions/fd89dff0-d96f-4bb5-a96b-e42d76c96492/resourceGroups/EAG-TST/providers/Microsoft.Compute/virtualMachines/EAG-TST-instigator,,,"{  ""ImageType"": null,  ""ServiceType"": null,  ""VMName"": null,  ""VMProperties"": null,  ""VCPUs"": 0,  ""UsageType"": ""DataTrIn""}","""ORG"": ""EAG"",""TYPE"": ""TST""",,Unassigned,,10 GB,EAG-TST,FALSE
###

my $sample_no_quotes = '/subscriptions/EAG-TST/providers/Microsoft.Compute/EAG-TST-instigator,,Canonical,"{  ""ImageType"": ""Canonical"",  ""ServiceType"": ""Standard_B1s"",  ""VMName"": null,  ""VMProperties"": null,  ""VCPUs"": 1,  ""UsageType"": ""ComputeHR""}","""ORG"": ""EAG"",""TYPE"": ""TST""",,Unassigned,,100 Hours,EAG-TST,False';


print "--------------------------------------------------------------------------\n";
$x = "Time to feed the cat!";
 print "\$x: $x\n";
$x =~ s/cat/hacker/;   # $x contains "Time to feed the hacker!"
 print "\nafter substitution:  \$x: $x\n";
print "--------------------------------------------------------------------------\n";
 
$y = "'quoted- words','morer-words','dog','cat','kitty kat'";
 print "\$y: $y\n";
$y =~ s/'([\w\s\-\d]*)'/$1/g;  # strip single quotes,
                           # $y contains "quoted words"
 print "\nafter substitution:  \$y: $y\n";
 print "\n";

#####
print "--------------------------------------------------------------------------\n";
my $z = $sample; 
 print "\$z: $z\n";

### """ORG"": ""EAG"",""TYPE"": ""TST"""
### """ORG"": ""EAG"",""TYPE"": ""TST"",""ORG"": ""EAG"""
### "{  ""ImageType"": ""Canonical"",  ""ServiceType"": ""Standard_B1s"",  ""VMName"": null,  ""VMProperties"": null,  ""VCPUs"": 1,  ""UsageType"": ""ComputeHR""}",
$z =~ s/("""[\.\w\:\d"\s]*),/$1XX/g;
$z =~ s/("{  [\.\w\:\d"\s]*),/$1ZZ/g;
print "\$z: $z\n";
my @array = split(/\"\,\"/,$z);
foreach my $ii ( 0 .. $#array ){
     print "[$ii]: $array[$ii]\n";
};

print "--------------------------------------------------------------------------\n";
my $z = $sample_no_quotes; 
 print "\$z: $z\n";

### """ORG"": ""EAG"",""TYPE"": ""TST"""
### """ORG"": ""EAG"",""TYPE"": ""TST"",""ORG"": ""EAG"""
### "{  ""ImageType"": ""Canonical"",  ""ServiceType"": ""Standard_B1s"",  ""VMName"": null,  ""VMProperties"": null,  ""VCPUs"": 1,  ""UsageType"": ""ComputeHR""}",
### Canonical,"{  ""ImageType"": ""Canonical"",  ""ServiceType"": ""Standard_B1s"",  ""VMName"": null,  ""VMProperties"": null,  ""VCPUs"": 1,  ""UsageType"": ""ComputeHR""}","""ORG"": ""EAG"",""TYPE"": ""TST""",,Unassigned

#         $z =~ s/("""[\.\w\:\d"\s]*"),/$1XX/g;
#         $z =~ s/("{  [\.\w\:\d"\s]*),/$1ZZ/g;
$z =~ s/(\,  "")/YY/g;                 
$z =~ s/("""[\.\w\:\d"\s]*),/$1XX/g;
##$z =~ s/("{  [\.\w\:\d"\s]*),/$1ZZ/g;
print "\$z: $z\n";
my @array = split(/\,/,$z);
foreach my $ii ( 0 .. $#array ){
     print "[$ii]: $array[$ii]\n";
};

print "--------------------------------------------------------------------------\n";
print "\n";

exit;


$y =~ s/"([\/\w\s\-\d]*)"/^$1^/g;  # strip single quotes,
                           # $y contains "quoted words"
 print "\nafter substitution:  \$y: $y\n";
 print "\n";
my @array = split(/"\,\"/,$y);
foreach my $ii ( 0 .. $#array ){
     print "[$ii]: $array[$ii]\n";
}; 
     
