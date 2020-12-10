#!/usr/bin/perl -w
#Written By Aravind Venkateswaran z5208102 
use URI::Escape;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
$ua = LWP::UserAgent->new;

if (! -f "$ARGV[0]"){
    print "File dosent exist\n";
    exit 1;
}

if("$ARGV[0]" !~ /\.fasta$/){
    print "File isn't in fasta format\n";
    exit 1;
}
system("getorf -sequence $ARGV[0] -minsize 150 -outseq orfs.orf >/dev/null 2>&1");

if($?){
    print "Not in correct format\n";
    exit 1;
}
my @queries;
my $infile = "orfs.orf";
open my $in, '<', $infile or die "Cannot open $infile: $!";
my @lines = <$in>;
close $in;
system("rm orfs.orf");
#THE BELOW CODE FOR RETREIVING BLAST RESULTS IS BASED ON: $Id: web_blast.pl,v 1.10 2016/07/13 14:32:50 merezhuk Exp $ code available @:
#https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=DeveloperInfo
$encoded_query = "";

foreach my $line (@lines){
    $encoded_query = $encoded_query . uri_escape($line);
}

$program = "blastp";
$database = "swissprot";

# build the request
$args = "CMD=Put&PROGRAM=$program&DATABASE=$database&QUERY=" . $encoded_query;

$req = new HTTP::Request POST => 'https://blast.ncbi.nlm.nih.gov/Blast.cgi?PROGRAM=blastp&PAGE_TYPE=BlastSearch&LINK_LOC=blasthome&WORD_SIZE=6';
$req->content_type('application/x-www-form-urlencoded');
$req->content($args);

# get the response
$response = $ua->request($req);

# parse out the request id
$response->content =~ /^    RID = (.*$)/m;
$rid=$1;

# parse out the estimated time to completion
$response->content =~ /^    RTOE = (.*$)/m;
$rtoe=$1;

# wait for search to complete
sleep $rtoe;

# poll for results
while (1)
    {
    sleep 5;

    $req = new HTTP::Request GET => "https://blast.ncbi.nlm.nih.gov/blast/Blast.cgi?CMD=Get&FORMAT_OBJECT=SearchInfo&WORD_SIZE=6&PROGRAM=blastp&DATABASE=swissprot&RID=$rid";
    $response = $ua->request($req);

    if ($response->content =~ /\s+Status=WAITING/m)
        {
        # print STDERR "Searching...\n";
        next;
        }

    if ($response->content =~ /\s+Status=FAILED/m)
        {
        print STDERR "Search $rid failed; please report to blast-help\@ncbi.nlm.nih.gov.\n";
        exit 4;
        }

    if ($response->content =~ /\s+Status=UNKNOWN/m)
        {
        print STDERR "Search $rid expired.\n";
        exit 3;
        }

    if ($response->content =~ /\s+Status=READY/m) 
        {
        if ($response->content =~ /\s+ThereAreHits=yes/m)
            {
            #  print STDERR "Search complete, retrieving results...\n";
            last;
            }
        else
            {
            print STDERR "No hits found.\n";
            exit 2;
            }
        }

    # if we get here, something unexpected happened.
    print "Possible Environment Error\n";
    exit 5;
    } # end poll loop

# retrieve and display results
$req = new HTTP::Request GET => "https://blast.ncbi.nlm.nih.gov/blast/Blast.cgi?CMD=Get&FORMAT_TYPE=Tabular&RID=$rid";
$response = $ua->request($req);
my $content = $response->content();
#THE ABOVE CODE FOR RETREIVING BLAST RESULTS IS BASED ON: $Id: web_blast.pl,v 1.10 2016/07/13 14:32:50 merezhuk Exp $ code available @:
#https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=DeveloperInfo
my @hits = split("Query:",$content);
#################Sorting orfs################################
my $seq = shift(@lines);
while($Element = shift(@lines)){
    if($Element =~ /^>/){
        push(@queries, $seq);
        $seq = $Element;
    }else{
            $seq= $seq.$Element;
        
    }
}
push(@queries,$seq);

my @sorted;

while(findmin(\@queries) ne ""){
    $query = findmin(\@queries);
    foreach $removal (@queries){
        if($removal eq $query){
            $removal = "";
        }
    }
    push(@sorted,$query);
}

sub findmin{
    my $min = 200000;
    my $minq = "";
    my @array = @{$_[0]};
      foreach $query (@array){
          
        if($query =~ / \[(\d+) \- (\d+)\] /){
           
            if($1 <= $min){
                $min = $1;
                $minq = $query;
            }
        }
    }
    return $minq;
}
#############BuildingCSV######################
my @header;
push(@header,"Start");push(@header,"End");push(@header,"Strand");push(@header,"Blast hit");push(@header,"E-value");
my $field = join(',',@header);
print "$field\n";

foreach $query (@sorted){
    #print "$query";
    $field = "";
    $query =~ / \[(\d+) \- (\d+)\] / ;
    $start = $1;
    $end = $2;
    if($query =~ / \(REVERSE SENSE\) /){
        $strand = "REVERSE";
    }else{
        $strand = "FORWARD";
    }
    $blasthit = "-";
    $Evalue = "-";
    $information = "";
    #print "$content\n";
    for $hit (@hits){
        if($hit =~ / \[$start \- $end\] /){
            if($hit =~ /hits found/){             
                @hitlines = split("\n",$hit);
                foreach $hitline (@hitlines){
                    if($hitline =~ /^[^( |#)]/){
                        $information = $hitline;
                        last;
                    }
                }
            }
            last;
        }
    }
    
    $Evalue = `echo $information | tr -s [:blank:] |cut -d ' ' -f11`;
    chomp $Evalue;
    if($Evalue ne ""){
        $Evalue = $Evalue +0;  
    }else{
        $Evalue = "-";
    }
    if($Evalue !~ /e/){
        $number = 1.000 + 0.0;
        if($Evalue ne "-"){
            if($Evalue >= $number){
                $Evalue = "-";
            }
    }       
    }
    
    if($Evalue ne "-"){
        $blasthit = `echo $information | tr -s [:blank:] |cut -d ' ' -f2`;
        chomp $blasthit;
    }
    $field = join(',',$start,$end,$strand,$blasthit,$Evalue);
    print "$field\n";

}
exit 0;


