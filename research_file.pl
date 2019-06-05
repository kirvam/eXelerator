use strict;
use warnings;
use Data::Dumper;

my $tag = shift; 
chomp($tag);
my $file = shift; 
chomp($file);
my $hh = 0;
## my $ii = 0;
## my $jj = 1;

open( my $fh, '<', $file ) || die "Flaming death on open of $file: $!\n";
while(<$fh>){
  if( $hh == 26 ){ 
    exit; 
   } else {

    my $line = $_;
     chomp($line);
      ## my $altline = $line;
      ## alt_split($altline);
      if( $line =~ m/^$/ ) { next; };
       print "$hh: \$line: $line\n";

        my $z = $line;
        #$z =~ s/("""[\.\w\d\s]*:[\.\w\d"\s]*),/$1XX/g;
        $z =~ s/("""[\.\w\:\d"\s]*"),/$1XX/g;
        $z =~ s/("{  [\.\w\:\d"\s]*),/$1ZZ/g;
        print "\n$hh: \$z: $z\n\n";
         my @array = split(/\"\,\"/,$z);
          foreach my $ii ( 0 .. $#array ){
                 print "[$ii]: $array[$ii]\n";
               };
      $hh++;
      print "\n";
      print "Array Count: $#array\n";
      ## alt_split($altline);
  };
};


sub alt_split {
print "\t--------sub alt_split start -------\n";
my($line) = @_;
my $ii =1;
my $jj =1;
 my @array = split($line);
 if( my $count = () = $line =~ m/("","""|""","")/g){ 
       print "\tmatches: $count\n";
  };
  $line =~ s/\"([\w\s\d\@\\-]*)\"/$1/g;
        print "\n\t\$line: $line\n\n";
        my @array = split(/,/,$line);
      print "\n\t$jj: $#array: $line\n";
      foreach my $kk ( 0 .. $#array ){
              print "\t$kk: $array[$kk]\n";
          };
      $jj++;
      print "\n";

# if( my $count = () = $line =~ m/(\w(")|(")\w)/g){ 
#       print "matches: $count\n";
#       $line =~ s/
#  }
print "\t--------sub alt_split end -------\n";
return($line);
}

