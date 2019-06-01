
my $sample = '"/subscriptions/fd89dff0-d96f-4bb5-a96b-e42d76c96492/resourceGroups/EAG-TST/providers/Microsoft.Compute/virtualMachines/EAG-TST-instigator","","Canonical","{  ""ImageType"": ""Canonical"",  ""ServiceType"": ""Standard_B1s"",  ""VMName"": null,  ""VMProperties"": null,  ""VCPUs"": 1,  ""UsageType"": ""ComputeHR""}","""ORG"": ""EAG"",""TYPE"": ""TST""","","Unassigned","","100 Hours","EAG-TST","False"';

my $sampleX = '"/subscriptions/EAG-TST/ms.co/providers/EAG-TST-instigator","","Canonical","""ORG"": ""EAG"",""TYPE"": ""TST""","","Unassigned","","100 Hours","EAG-TST","False"';




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
print "\n";

exit;


$y =~ s/"([\/\w\s\-\d]*)"/^$1^/g;  # strip single quotes,
                           # $y contains "quoted words"
 print "\nafter substitution:  \$y: $y\n";
 print "\n";
my @array = split(/\"\,\"/,$y);
foreach my $ii ( 0 .. $#array ){
     print "[$ii]: $array[$ii]\n";
}; 
     
