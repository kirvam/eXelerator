use strict;
use warnings;
use Data::Dumper;

my $file = shift;
chomp($file);
my $fname = shift;
my %HoA;
my $markup = '0.05';

#my @sheading = (
#                'Org',
#                'VmName',
#                'numCPU',
#                'memoryMB',
#                'Provisioned',
#                'Used',               
#                'Remaining%',
#                'StorageCost',
#                'VmCost',
#                'Total'
#);


#my @sheading = (
#               'Subscription Name',
#               'Date',
#               'Product',
#               'Meter Category',
#               'Meter Sub-Category',
#               'Meter Name',
#               'Consumed Quantity',
#               'ReourceRate',
#               'ExtendedCost',
#               'Instance ID',
#               'Tags',
#               'Unit Of Measure' 
#);
### @headings, You need to know the headings AND remove any (\s) spaces.
my @sheading = (
                    'SubscriptionName',
                    'Date',
                    'Product',
                    'MeterCategory',
                    'MeterSub-Category',
                    'MeterName',
                    'InstanceID',
                    'Tags',
                    'UnitOfMeasure',
                    'ConsumedQuantity',
                    'ResourceRate',
                    'ExtendedCost'
                );

###my ($file,$headings) = parse_file($file);
###make_array_and_count($headings);
print "\n---< Start $0 >---\n";
# GLOBAL MAP
#my($map_href) = mk_data_map();
my ($map_href);
#
# numCPU [3 + 1 = 4]
# memoryMB [4 + 1 = 5]
# Provisioned [5 + 1 = 6]
#my($refHoA,$refHoAdata,$header_aref) = proc_file($file,'VM Name','Annot','numCPU','memoryMB','Provisioned','Used','Remaining');
### You need to install headings as a 12 tags to create MAP HASH.  Yes this could be converted to an array in the future.
my($refHoA,$refHoAdata,$header_aref) = proc_file($file,'SubscriptionName','Date','Product','MeterCategory','MeterSub-Category','MeterName','ConsumedQuantity','ResourceRate','ExtendedCost','InstanceID','Tags','UnitOfMeasure');

print "Dumper \$header_aref";
print Dumper \$header_aref;

my(@header) = mk_array($header_aref);
print "Dumper \@header\n";
print Dumper \@header;
print Dumper \$refHoA;
print_hash_ref($refHoA);
print_hash_ref($refHoAdata);


#exit;

# $refHoA) = make_fields_new($fname,$headings,%HoA);
#print "Dumper for \$refHoA\n";
#print Dumper \$refHoA;
#print_hash_ref($refHoA);
iterate_array($fname,$refHoAdata,@sheading);

print "--< End >--\n";



# SUBS
#
###
sub mk_array {
my($aref) = @_;
my @header;
foreach my $item ( @{ $aref } ){
  push @header, $item;
  };
 return(@header);
};
#

sub conv_{
my($value,$stype) = @_;
my $gb;
my $tb;
my %table = (
           'B' => sub { my ($val) = @_;
                        $val = ( $val/1073741824 );
                        return $val;
                      },
           'G' => sub { my ($val) = @_;
                        $val = ( $val/1000 );
                        return $val;
                      }
           #'M' => sub { my ($val) = @_;
           #             $val = ( $val/1024 );
           #             return $val;
          );
if ( $stype eq 'B' ) {
      $gb = $table{$stype}->($value);
      $tb = conv_($gb,'G');
       } else {
        $gb = $value;
        $tb = $table{$stype}->($value);
     };
$gb = sprintf("%.2f", $gb);
$tb = sprintf("%.2f", $tb);
   return($gb,$tb);
};

#
sub gen_cost {
my($mem,$cpu,$prov) = @_;
# (1482.5+100*($mem - 1)*1.009^($mem - 1)+300*($cpu - 1)+($prov * 3.18))
my $cost = ( 1482.5+100*($mem - 1)*1.009**($mem - 1)+300*($cpu - 1)+($prov * 3.18)) ;
my $pretty = sprintf("%.2f", $cost);
my $stor = ($prov * 3.18);
   $stor = sprintf("%.2f", $stor);
my $vmc = (1482.5+100*($mem - 1)*1.009**($mem - 1)+300*($cpu - 1));
   $vmc = sprintf("%.2f", $vmc);
return($cost,$pretty,$stor,$vmc);
};


sub proc_file {
# 'Subscription Name','Date','Product','Meter Category','Meter Sub-Category','Meter Name','Consumed Quantity','ResourceRate','ExtendedCost','Instance ID','Tags','Unit Of Measure'); 
my($file,$key_sub,$key_date,$key_prod,$key_metercat,$key_metersub,$key_mname,$key_consumed,$key_resrate,$key_extend,$key_id,$key_tags,$key_unit) = @_;
#my($file,$key_num,$key_note,$key_cpu,$key_mem,$key_prov,$key_used,$key_remain) = @_;
#$key_num =~ s/\s//g;
$key_sub =~ s/\s//g;
my $ii;
my %HoA;
my %HoAdata;
my %map;
my @header;
my @nheader;
my @fheader;
open ( my $fh, "<", $file ) || die "Flaming death on open of $file: $!\n";
while(<$fh>){
  $ii++;
  if( $ii eq 1 ) { print "$ii: FOUND 1: NEXT!\n"; next; }; 
  if( $ii eq 2 ) { print "$ii: FOUND 2: NEXT!\n"; next; }; 
  my $line = $_;
  chomp($line);
  print "\n\n$ii: FIRST LOOK: ^$line^\n";
  #if( $ii lt 3 ){ print "NEXT\n";next ; };
  #$line =~ s/\s*//g;
  #print "^$line^\n";
  if( $ii eq 3 ){
    print "FOUND line 3 /Header.\n";
    @header = split(/,/,$line);
    my $hline;
    foreach my $kk ( 0 .. $#header ){
            my $key = $header[$kk];
            $key =~ s/\s*//g;
            # for AZC
            $key =~ s/\"//g;
            print "HEADER KEY: $key\n";
            $hline .= ",".$key;
            push @nheader, $key;
            $map{$key} = $kk;
          };
             my $fnum = $#header + 1;
             print "$ii,line has $fnum fields.\n";
             push @{ $HoA{header} }, [ $hline ];
             #push @{ $HoAdata{header} }, [ $line ];
        } elsif ( $ii gt 1 && $_ =~ m/^#/ ) {
                print "F4: FOUND OTHER Header.\n";
                next;
      #  } elsif ( $ii =~ /(1|2)/){
      #         print "$ii: FOUND LINE 1 or 2\n";
      #          next;
         }  else {   
                   print "DATA LINE\n";
                   my $line = line_fixer($line);
                   # for AZC
                   $line =~ s/\"//g;
                    #my @line = split(/\"\,\"/,$line);
                    my @line = split(/,/,$line);
                    my $fnum = $#line + 1;
                    my $ksub = $map{$key_sub};
                    push @fheader, $ksub;
                     $ksub = $line[$ksub];
                    my $kdate = $map{$key_date};
                    push @fheader, $kdate;
                     $kdate = $line[$kdate];
                    my $kprod = $map{$key_prod};
                    push @fheader, $kprod;
                     $kprod = $line[$kprod];
                    my $kmetercat = $map{$key_metercat};
                    push @fheader, $kmetercat;
                     $kmetercat = $line[$kmetercat];
                    my $kmetersub = $map{$key_metersub};                   
                    push @fheader, $kmetersub;
                     $kmetersub = $line[$kmetersub];
                    my $kmname = $map{$key_mname};
                    push @fheader, $kmname;
                     $kmname = $line[$kmname];
                    ###
                     my $kid = $map{$key_id};
                     push @fheader, $kid;
                     $kid = $line[$kid];
                       my @junk = split(/\//,$kid);
                       $kid = $junk[$#junk];
                       print "\$kid: $kid\n";
                     my $ktags = $map{$key_tags};
                     push @fheader, $ktags;
                     $ktags = $line[$ktags];
                     my $kunit = $map{$key_unit};
                     push @fheader, $kunit;
                     $kunit = $line[$kunit];
                    ###
                    my $kconsumed = $map{$key_consumed}; 
                    push @fheader, $kconsumed;
                     $kconsumed = $line[$kconsumed];
                    my $kresrate = $map{$key_resrate};
                    push @fheader, $kresrate;
                     $kresrate = $line[$kresrate];
                    my $kextend = $map{$key_extend};
                    push @fheader, $kextend;
                     $kextend = $line[$kextend];
                    ### my $kid = $map{$key_id};
                    ### print "MAP: $map{$key_id}\n";
                    ### print "MAP: $kid\n";
                    ### $kid = $line[$kid];
                    ###  print "\$kid: $kid\n";
                    ###  my @junk = split(/\//,$kid);
                    ###   $kid = $junk[$#junk];
                    ###   print "\$kid: $kid\n";
                    ### my $ktags = $map{$key_tags};
                    ###  $ktags = $line[$ktags];
                    ###    print "\$ktags: $ktags\n"; 
                    ### my $kunit = $map{$key_unit};
                    ###  $kunit = $line[$kunit];
                    #my $used = $map{$key_used};
                    # my $remain = $map{$key_remain};
                    #$remain = $line[$remain];
                    #$used = $line[$used];
                    #my $used_t;
                    #($used,$used_t) = conv_($used,'B');
                    #$cpu = $line[$cpu];
                    #   print "CPU: $cpu\n";
                    #my $mem = $map{$key_mem};
                    #$mem = $line[$mem];
                    #$mem = ( $mem /1024 );   # converts B to MB
                    #   print "MEM: $mem\n";
                    #my $prov = $map{$key_prov};
                    #$prov = $line[$prov];
                    #   print "PROV: $prov\n";
                    #my $prov_t;
                    #($prov,$prov_t) = conv_($prov,'B');
                    #   print "PROV: $prov\nPROV_T: $prov_t\n";
                    #   my($cost,$pretty,$stor,$vmc) = gen_cost($cpu,$mem,$prov);
                    print "$ii,line has $fnum fields. \$ksub: $fnum\n";
                    #my $vname = $line[$knum];
                    #my $val = $line[$knum];
                    #my $note = $line[$knote];
                    #print "NOTE1: $note\n";
                    #$note =~ s/\,//g;
                    #print "NOTE2: $note\n";
                    #my $val = find_name($val,$note);
                    $ksub =uc($ksub);
                    # $line = $line."
                    ## $line = $line.",".$ksub.",".$kdate.",".$kprod.",".$kmetercat.",".$kmetersub.",".$kmname.",".$kconsumed.",".$kresrate.".".$kextend,",".$kunit.",".$kid.",".$ktags;
                    #$line = $ksub.",".$kdate.",".$kprod.",".$kmetercat.",".$kmetersub.",".$kmname.",".$kconsumed.",".$kresrate.",".$kextend.",".$kunit.",".$kid.",".$ktags;
                    #$line = "$ksub,$kdate,$kprod,$kmetercat,$kmetersub,$kmname,$kconsumed,$kresrate,$kextend,$kid,$ktags,$kunit";
                    $line = "$ksub,$kdate,$kprod,$kmetercat,$kmetersub,$kmname,$kid,$ktags,$kunit,$kconsumed,$kresrate,$kextend";

                    print "LOOK AT WHOLE LINE AND FIELDS:\n";
                    print "^$line^\n";
                    push @{ $HoA{$ksub} }, [ $line ];
                    #my $line = $val.",".$vname.",".$cpu.",".$mem.",".$prov.",".$used.",".$remain.",".$stor.",".$vmc.",".$pretty;
                    #my $line = $ksub.",".$kdate.",".$kprod.",".$kmetercat.",".$kmetersub.",".$kmname.",".$kconsumed.",".$kresrate.".".$kextend,",".$kunit.",".$kid.",".$ktags; 
                    #print  "^$val,$vname,$cpu,$mem,$prov,$used,$remain,$stor,$vmc,$pretty^\n";
                    print "^$line^\n";
                    print "Print Array:\n";
                    my @array = split(/,/,$line);
                       foreach my $hh ( 0 .. $#line ){
                              print "[$hh]: $line[$hh]\n";
                        };
                      push @{ $HoAdata{$ksub} }, [ @array ];
  };
 };
 print "\nHeader 2nd:\n";
  foreach my $item ( 0 .. $#nheader ){
           my $val = $item + 1;
           print "$nheader[$item] [$item + 1 = $val]\n";
   }
  #print "\nREVISED HEADER ORDER\n";
  #foreach my $item ( @fheader ){
  #         my $val = $nheader[$item];
  #         print "\$item: $item: $nheader[$item]\n";
  # }
   
  print "\nTotal lines: $ii.\n";
 return(\%HoA,\%HoAdata,\@nheader);
};

sub line_fixer {
my($line) = @_;
my $z = $line;
        ##$z =~ s/("""[\.\w\d\s]*:[\.\w\d"\s]*),/$1XX/g;
        $z =~ s/(\,  "")/YY/g;
        $z =~ s/("""[\.\w\:\d"\s]*"),/$1XX/g;
        #$z =~ s/("{  [\.\w\:\d"\s]*),/$1ZZ/g;
        #print "\n$hh: \$z: $z\n\n";
       #my @array = split(/\"\,\"/,$z);
  chomp($line);
return($z);
}

###
sub find_name {
my($vm,$tag) = @_;
my $val;
my $ii;
my $date = get_date();
my $xfile = "exceptions_".$date."_.csv";
open( my $fh ,'>>', $xfile ) || die "Flaming death on open of $xfile: $!\n";
if ( ${$map_href}{$vm} ) {
            print "F3: FoundExp, in Exceptions File: \${$map_href}{$vm} =  ${$map_href}{$vm}\n";
            $vm = ${$map_href}{$vm};

       } elsif ($vm =~ m/(^
              	 CS|
                ADS|
               ACCD|
                AGO|
		AGR|
		AHS|
		ANR|
		AOT|
		BGS|
		DII|
		DLC|
		DPS|
		E911|
		EAG|
                ENT|
                EDU|
		ERP|
		JUD|
		NRB|
		PSD|
		PSB|
		SAS|
		TAX|
                VIC|
		VCGI|
                VDOL|
		VLC|
		VVH|
                vShield-Edge|
		TRE       
                 )/ixg
                ){
      print "F1: FIRST: Found match: $1\n";
      $vm = $1;
   } elsif (
      $tag =~ m/(^
		 CS|  
                ADS|
               ACCD|
                AGO|
                AGR|
                AHS|
                ANR|
                AOT|
                BGS|
                DII|
                DLC|
                DPS|
                E911|
                EAG|
                ENT|
                EDU|
                ERP|
                JUD|
                NRB|
                PSD|
                PSB|
                SAS|
                TAX|
                VIC|
                VCGI|
                VDOL|
                VLC|
                VVH|
                TRE       
                 )/ixg
                   ){
                     print "F2: 2ND: Found match: $1\n";
                     $vm = $1;
         } else {  
             #  elsif ( ${$map_href}{$vm} ) {
             #        print "F3: FoundExp, in Exceptions File: \${$map_href}{$vm} =  ${$map_href}{$vm}\n";
             #        $vm = ${$map_href}{$vm}; 
             # } else {   
             print "NF: LAST NO MATCH: $vm\n";
             print $fh "$vm\n";
   };
  if( $vm =~ m/^ENT/i ) { $vm = 'ADS' } ;
  return($vm);
};

sub get_date{
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                localtime(time);
$year += 1900;
$mon += 1;
$mday = sprintf("%02d", $mday);
my $date = $year."-".$mon."-".$mday;
return ($date);
}

sub make_fields_new {
my($file,$headings,$refHoA) = @_;
my @headings = split(/,/,$headings);
open ( my $fh, "<", $file ) || die "Flaming death on open: $!";
while (<$fh>){
my $line = $_;
chomp($line);
$line =~ s/\s*//g;
my @line = split(/,/,$line);
my @array;
print "\n";
 };
};



sub iterate_array {
# sub to create tabs for each tag/key in HoA
my($name_for_sheet,$ref,@heading) = @_;
use Excel::Writer::XLSX;
$name_for_sheet = $name_for_sheet."\.xlsx";
my $workbook = Excel::Writer::XLSX->new( $name_for_sheet );
print "---< Start iterate_array >---\n";
my $totals = "TOTALS";
my $worksheettotal = $workbook->add_worksheet( $totals );
  my $total_tab_start = 4;
  my $trow = 3;
  my $new_c;
 my $formath = $workbook->add_format();
      $formath->set_bold(1);
      $formath->set_align('left');
      $formath->set_bg_color('green');
      $formath->set_color('white');
      $formath->set_font('Tahoma');
      $formath->set_size('10');
         foreach my $ii ( 0 .. $#heading ){
           print "write line: 2, $ii, $heading[$ii]\n";
             $worksheettotal->write( 2, $ii, $heading[$ii], $formath  );
         };

foreach my $key ( sort ( keys %$ref ) ){
  print "$key:\n";
  if($key =~ m/Owner/gi){ print "found Owner: $key.\n"; next; };
  #if($key =~ m/eag/gi){ print "found Owner: $key.\n"; next; };
  if($key =~ m/cs/gi){ print "found Owner: $key.\n"; next; };
  if($key =~ m/vshield/gi){ print "found Owner: $key.\n"; next; };
  if($key =~ m/name/gi){ print "found Owner: $key.\n"; next; };
  
  
# Add a worksheet
   my $worksheet = $workbook->add_worksheet( $key );
   my $format = $workbook->add_format();
      $format->set_bold(1);
      $format->set_align('left');
      $format->set_bg_color('green');
      $format->set_color('white');
      $format->set_font('Tahoma');
      $format->set_size('10');
         print "write line: 0, 0, $key\n";
         $worksheet->write( 0, 0, $key, $format );
            foreach my $ii ( 0 .. $#heading ){
              print "write line: 2, $ii, $heading[$ii]\n";
               $worksheet->write( 2, $ii, $heading[$ii], $format  );
                  };
# set row to start on row 2 to allow for header..
      my $col = 0; my $row = 3;
      #my $total_tab_start = $row; $total_tab_start++;
      my $start_col = $#heading; 
      my $start_row = $row+1;
      my $sum_start = "S".$start_row;  print "\$start_col: $start_col\n";   ###########  here...
      
       my $format1 = $workbook->add_format();
          $format1->set_bold(0);
          $format1->set_bg_color();
          $format1->set_color();
          $format1->set_font( 'Tahoma' );
          $format1->set_size( '10' );

       foreach my $ii ( 0 .. $#{@{$ref}{$key}} ){
          my @array = @{ ${$ref}{$key}[$ii] } ;
             foreach my $jj ( 0 .. $#array ){
               #$col = $ii+2; # controls start of column
                 $col = $jj;
                  print "write line: $row, $col, $array[$jj]\n";
                    $worksheet->write( $row, $col, $array[$jj], $format1 );
                  print "write totals line: $trow, $col, $array[$jj]\n";
                    $worksheettotal->write( $trow, $col, $array[$jj], $format1 );
                    
                    print "\t$ii,$jj: $array[$jj]\n";
              }
###
###                  
            $row++;
            $trow++;
       }
          ## col 18
          my $final_row = $row;
          my $place_row = $final_row+1;
          my $final_col = $start_col;
          my $sum_end = "S".$final_row;
          print "\$sum_end: $sum_end\n";
          my $sum = "\=sum\($sum_start:$sum_end\)";
           print "\$sum: $sum\n";
           print "write line: $row, $final_col, $sum\n";
          #my $final_col = $start_col-1;
          ###
          ###  Bbuilding total column for Azure Subtotal
          my $sum_end = "L".$final_row;
          my $sum_start = "L".$start_row;
          ###
          my $vsum = "\=sum\($sum_start:$sum_end\)";
            print "\$sum: $sum\n";
          #my $vm_col = $final_col;
          #   print "write line: $row, $vm_col, $vsum\n";
          #
          my $t_col = $start_col - 1;
          $row = $row+2;
          my $tab_subtotal = 'Azure Subtotal';
          print "write line: $row, $t_col, $tab_subtotal\n";
          $worksheet->write( $row, $t_col, $tab_subtotal, $formath );
          
          my $t_col = $t_col+1;
          print "write line: $row, $t_col, $vsum\n";
          $worksheet->write( $row, $t_col, $vsum, $format1 );
          $new_c = $col;

          ###
          $row++;
          # Build Charge field.
          my $stv_next_row = $final_row + 3;
            print "\$stv_next_row: $stv_next_row\n";
          my $sum_cs_fee_val = "=(L".$stv_next_row." * $markup)"; 
            print "\$stv_cs_fee_val: $sum_cs_fee_val\n";       
          # Build Charge Msg
          my $back_one_col = $t_col - 1;
          my $charge_msg = 'CS Service Charge';
            print "write \$charge_msg: $row, $back_one_col, $charge_msg\n";
          $worksheet->write(  $row, $back_one_col, $charge_msg, $formath);
            print "write cs fee: $row, $t_col, $sum_cs_fee_val\n";
          $worksheet->write( $row, $t_col, $sum_cs_fee_val );
          ## 
          # Build Grand Total
          $row++;
          my $stv_next_row_next = $stv_next_row + 1;
          my $gtotal = "=( L".$stv_next_row." + "."L".$stv_next_row_next." )";
            print "write \$gtotal: $gtotal\n";
          my $gtotal_msg = 'Grand Total'; 
            print "write \$gtotal_msg: $gtotal_msg\n";
          $worksheet->write( $row, $back_one_col, $gtotal_msg, $formath);
              print "write gtotal: $row, $t_col, $gtotal\n";
          $worksheet->write( $row, $t_col, $gtotal);

           
          ###
      };
                 #my $new_c = $col; $new_c++;
                 #my $new_row = $row; $new_row++;
                 #my $new_trow = $trow; $new_trow++;
                 my $new_trow = $trow;  
               #$new_trow--;
                 #my $sum_field = "=sum("."R".$new_row.":"."S".$new_row.")";  print $sum_field, "\n";
                 #my $sum_total_field = "=sum("."T".$total_tab_start.":"."T".$new_trow.")";  print $sum_total_field, "\n";
                 ###
                 my $sum_total_field = "=sum("."L".$total_tab_start.":"."L".$new_trow.")";  print $sum_total_field, "\n";
                 my $stv_next_row = $new_trow + 1;
                  print "\$stv_next_row: $stv_next_row\n";
                 my $sum_cs_fee_val = "=(L".$stv_next_row." * $markup)";
                  print "\$sum_cs_fee_val: $sum_cs_fee_val\n";
                 my $stv_next_row_next = $stv_next_row + 1;
                 my $gtotal = "=( L".$stv_next_row." + "."L".$stv_next_row_next." )";
                 print "write final totals sum cell: $trow, $new_c, $sum_total_field\n";
                 my $subtotal = "Azure Subtotal";
                 $worksheettotal->write( $trow, $new_c - 1, $subtotal, $formath );
                 $worksheettotal->write( $trow, $new_c, $sum_total_field );

                 $trow++;
                 my $back_one_col = $new_c - 1;
                 my $charge_msg = 'CS Service Charge';
                 print "write \$charge_msg: $trow, $back_one_col, $charge_msg\n";
                 $worksheettotal->write(  $trow, $back_one_col, $charge_msg, $formath);
                 print "write cs fee: $trow, $new_c, $sum_cs_fee_val\n";
                 $worksheettotal->write( $trow, $new_c, $sum_cs_fee_val );
                 $trow++;
                 my $gtotal_msg = 'Grand Total';
                 print "write \$gtotal_msg: $gtotal_msg\n";

                 $worksheettotal->write( $trow, $back_one_col, $gtotal_msg, $formath);
                 print "write gtotal: $trow, $new_c, $gtotal\n";
                 $worksheettotal->write( $trow, $new_c, $gtotal);

    
print "---< End iterate_array >-----\n";
};

###
sub mk_data_map {
my(%map) = ();
my $ii;
while(<DATA>){
  $ii++;
  my $line = $_;
  chomp($line);
  my($vm,$tag) = split(/,/,$line);
  $map{$vm} = $tag;
  print "$ii: Making tag: \$map{$vm} = $tag\n";
 };
 print"\n";
return(\%map);
};

sub print_hash_ref {
# sub to print HoA
my($ref) = @_;
print "\n\n---< Start print_hash_ref Sub >-----\n";
 foreach my $key ( sort ( keys %$ref ) ){
      print "$key:\n";
       foreach my $ii ( 0 .. $#{@{$ref}{$key} } ){
             my @array = @{ ${$ref}{$key}[$ii] } ;    
            #foreach my $jj ( 0 .. $#{ @{$ref}{$key}[$ii] } ){
                 #if($#array < 18){ print "LESS than 18\n";};
                foreach my $jj ( 0 .. $#array ){
                     print "\t$ii,$jj: $array[$jj]\n";
                      };
               ### print "\t$ii: ${$ref}{$key}[$ii][$jj]\n";
       };
 };
print "---< End print_hash_ref Sub >-----\n";
};

sub print_fields {
my($fields) = @_;
print "There needs to be: $fields.\n";
};

sub make_array_and_count{
print "\n---make_array_and_count---\n";
# $array should be split by comma,",".
my($headings) = @_;
my @headings = split(/,/,$headings);
print "\nNumber of Headings:\n";
for my $ii ( 0 .. $#headings ){
     print "$headings[$ii] [$ii ++ 1]\n";
 }
};

sub make_fields{
print "\n--make-fields---\n";
my($file,$headings,$refHoA) = @_;
my @headings = split(/,/,$headings);
open ( my $fh, "<", $file ) || die "Flaming death on open: $!";
while (<$fh>){
my $line = $_;
chomp($line);
$line =~ s/\s*//g;
my @line = split(/,/,$line);
my @array;
print "\n";
for my $ii ( 0 .. $#headings ){
     #print "\$ii: $ii\n";
     if( ! $line[$ii] ){ #print "Found NO VAL.\n"; 
        $line[$ii] = "0";
    } 
###
     my $val = $line [$ii];
     $val =~ s/\r//;
###    
###    push @array, $line [$ii];
       push @array, $val;
     #print "$headings[$ii] => $line[$ii]\n";
  }
    if( $array[9] eq "0" ){ print "--FOUND NO OWNER, $array[0]\n";
         if ( $array[0] =~ m/^(\w{3,})\-/g ){
              $array[9] = $1;
               print "--$1\n";
             } else {
                 print "--CST\n";      
                 $array[9] = "CST";
        }
  }
     for my $ii ( 0 .. $#array){
         print "$headings[$ii]=>$array[$ii]\n";
    }
###
my $owner = $array[0];
my @owner_split = split(/-/,$owner);
my $owner = $owner_split[0];

my @disk = split(/\s\s/,$array[6]);
my @disku = split(/\s\s/,$array[7]);
 
if($disk[1] =~ m/TB/ixg){ 
   $array[6] = $disk[0] * 1024;
  } else {
    $array[6] = $disk[0];
};
if($disku[1] =~ m/TB/ixg){ 
   $array[7] = $disku[0] * 1024;
  } else {
    $array[7] = $disku[0];
};

###
#   my $owner = $array[9];
   if(${$refHoA}{$owner}){
          push @{ $refHoA->{$owner} }, [ @array ];
      }  
    else {
       @{ $refHoA->{$owner} } = [ @array ];
       }
#     print Dumper \$refHoA;
 }
close $fh;
return ($refHoA);
};

sub parse_file {
my($file) = @_;
my $ii = 0;
my $jj = 0;
my $headings;
open ( my $fh, "<", $file ) || die "Flaming death on open: $!";
while (<$fh>){
$ii++;
my $line = $_;
chomp($line);
$line =~ s/\s*//g;
if ($ii eq 1){ $headings = $line;
    print $headings,"\n";
    };
my @array = split(/,/,$line);
#print Dumper \@array;
my $count = $#array;
print "count: $count\n";
$jj++;
 }
close $fh;
print "Here are the headings:\n$headings\n";
print "Total lines: $jj\n";
return($file,$headings);
};

__DATA__
AZURETEST,EAG
AzureLinuxtest01,EAG
AzureMigrate,EAG
Azuretest01,EAG
Cisco_FP_Mgmt_Ctr,EAG
DBFMDEV02,ERP
DBHRDEV02,ERP
DEV-ACD4-CCS,EAG
DEV-ACD4-CIC1,EAG
DFSFIREDB,DPS
DFSFIREDEV,DPS
EACS-gitlab-01,EAG
FMDEV2WEB01,ERP
FMPRDWEB02,ERP
FMSES,ERP
HRDEV2APP01,ERP
HRDEV2WEB01,ERP
HRSES,ERP
KSEWELL-VM,ERP
KWAKEFIELD-VM,ERP
MBUTRYMAN-VM,ERP
OEL_65_x64,EAG
TRACKIT,DPS
W2008r2std,EAG
W2012-R2_X64-50GB,EAG
W2K8-R2_X64-50GB,EAG
W2K8-R2_X64-50GB-old,EAG
W2K8-R2_x64_50GB,EAG
Win2016Test-Jim,EAG
Win2016Test2-Jim,EAG
oel6_64bit-50GB,EAG
oel7_64bit-50GB,EAG
vShield-Edge-EA-0,EAG
vShield-Edge-EA-1,EAG
vShield-Edge-GEN-0,EAG
vShield-Edge-GEN-1,EAG
w2k12-dc_x64,EAG
w2k12-dc_x64_r2,EAG
w2k16-dc_x64-50GB,EAG
w2k8-r2_x64_50gb,EAG
VMName,EAG
ABDEVAPP01,ERP
BIG-IPVE13.1.0.2.0.0.6,ERP
CS-Test2016-A,EAG
CS-Test2016-B,EAG
Call-APP01-01,VDOL
Call-DB01-01,VDOL
Call-DB2-VOIP-01,VDOL
Call-DC01-01,VDOL
Call-DC02-01,VDOL
Call-HS3-VOIP-01,VDOL
EACS-Eyeglass-TEMPLATE,EAG
FMSBX4APP01,ERP
Gruyere,EDU
Havarti,EDU
ScaleIO-10.216.34.201,EAG
ScaleIO-10.216.34.202,EAG
ScaleIO-10.216.34.203,EAG
ScaleIO-10.216.34.204,EAG
ScaleIO-10.216.34.205,EAG
ScaleIO-10.216.34.206,EAG
ScaleIO-10.216.34.207,EAG
ScaleIO-10.216.34.208,EAG
ScaleIO-10.216.34.209,EAG
ScaleIO-10.216.34.210,EAG
ScaleIO-10.216.34.211,EAG
ScaleIO-10.216.34.212,EAG
ScaleIO-10.216.34.213,EAG
ScaleIO-10.216.34.214,EAG
ScaleIO-10.216.34.215,EAG
ScaleIO-10.216.34.216,EAG
ScaleIOVM_2nics_2.0.13000.211,EAG
VM-VM-VM-VM-w2k16-dc_x64-50GB,EAG
VTADS-Thyme,JUD
Win2016Test,EAG
Win2016Test2,EAG
Win2016Test3-WAN,EAG
aaron-test,EAG
pfSense-2.4.4.1,EAG
test-01,EAG
vShield-Edge-EX-0,EAG
vShield-Edge-EX-1,EAG
vShield-Edge-GEN-0,EAG
vShield-Edge-GEN-1,EAG
vShield-Edge-VxRack-0,EAG
vShield-Edge-VxRack-1,EAG
w2k16-dc_x64-50GB,EAG
w2k16-dc_x64-50GB-old,EAG
VxRailManager,EAG
EACS-TEST-03,EAG
EACS-TEST-01,EAG
EACS-TEST-02,EAG
EACS-GITLAB-01,EAG
EACS-GitLab-01,EAG
VMwarevRealizeLogInsight,EAG
pfSense-2.4.4-p1,EAG
eacs-test-01,EAG
eacs-test-03,EAG
kentest2,EAG
ph-CentOS7-firebrand,EAG
ph-CentOS7-wavemaker,EAG
ph-CentOS7-zealot,EAG
CentOSTest,EAG
VMwarevCenterServerAppliance,EAG
VMwarevCenterServerPlatformServicesControl,EAG
CentOS7,EAG
CentOSTest-Jima,EAG
vShield-Edge-DIIDMZ-0,EAG
vShield-Edge-DIIDMZ-1,EAG
vShield-Edge-DII-0,EAG
vShield-Edge-DII-1,EAG
vShield-Edge-DIIDMZ-0,EAG
vShield-Edge-DIIDMZ-1,EAG
Win10-x64_ERP,EAG
VTADS-Ginger,JUD
VTADS-Nutmeg,JUD
VTADS-Parsley,JUD
VTADS-Rosemary,JUD
VTADS-Saffron,JUD
VTADS-Sage,JUD
VTADS-Slothrup,JUD
VTADS-Thyme,JUD
