#!/usr/bin/perl -w
#

use strict;

# Nicer implementation than File::Path
use Cwd 'abs_path';
use FindBin qw($Bin);
use File::Path;
use File::Spec;
use File::Basename;
use Getopt::Long;
use Text::CSV;

my $usage = qq{

  $0 
    --output-config-file
    --output-log-file
    [options]

    Takes as input CSV files containing DICOM attributes or fields to be emptied, removed, or replaced.
    
    See the options below for details of the required CSV format.

    Flywheel uses DICOM keywords, rather than tags. But we include the tags for reference.


  Required args:
    
   --output-config-file
     Output config file, should have extension ".yaml".


  Options:

   --empty-list
     List of fields to empty, in a CSV file. The CSV file should be in the format

       Tag,Keyword
       (0000,0000),TagKeyword

     Fields on this list will be set to an empty string, but the attribute will remain in the header.


   --remove-list
     List of attributes to remove, in a CSV file. The CSV file should be in the format

       Tag,Keyword
       (0000,0000),TagKeyword

     Attributes on this list are removed entirely. 


   --replace-list
     List of tags to replace with a constant string, in a CSV file. The CSV file should be in the format

       Tag,Keyword,Replacement
       (0000,0000),TagKeyword,"This field replaced by my string"

     Be careful with data types when replacing fields. The replacement is done by the fw tool and it is unknown 
     how it will handle invalid replacements, eg if you try to replace a numeric field with non-numeric characters. 
   
 
   --output-log-file
     File to place log information, including the value of fields before and after processing.

     This file should be specified with an absolute path and have the extension ".csv".

     Logging is disabled by default because the log file will contain identifiers. Use this option to keep a record 
     of what was taken out of the DICOM headers.
 
     The log file is written by the fw tool and will show the state of each field before and after processing.
 
     The log file will contain PHI. CONTAIN PHI. *** CONTAIN PHI ***. 

 
  Output:

    Config files for use with fw. If a log directory is specified, the config file will include logging instructions.
    Unless the data is already de-identified, the log will CONTAIN PHI.


  Limitations:

    Tags to be emptied are created if they do not exist.

    No support for modifying private tags, but this may be added in the future.


  Dependencies:

   Requires the Perl Text::CSV module.



};


if ($#ARGV < 0) {
    print $usage;
    exit 1;
}

my $emptyCSV = "";
my $removeCSV = "";
my $replaceCSV = "";

# The log is disabled by default
my $outputLogFile;

my $outputConfigFile;


GetOptions ("empty-list=s" => \$emptyCSV,
	    "remove-list=s" => \$removeCSV,
            "replace-list=s" => \$replaceCSV,  
	    "output-config-file=s" => \$outputConfigFile,
            "output-log-file=s" => \$outputLogFile
    )
    or die("Error in command line arguments\n");

# Check we can read all files if they are provided
foreach my $tagList ($emptyCSV, $removeCSV, $replaceCSV) {
    if ($tagList && ! -f $tagList) {
        die("Cannot read list of tags from $tagList");
    }
}

# Hard code some defaults

my $deIDLogString = "# deid-log: /my/example/logContainingPHI.csv";

if ($outputLogFile) {

    my ($logBaseName, $logDir, $logSuffix) = fileparse($outputLogFile, ".csv");

    if (!($logSuffix && $logSuffix eq ".csv")) {
        $logSuffix = ".csv";
    }

    my $fullPathToLogFile = "${logDir}${logBaseName}${logSuffix}";

    $deIDLogString = "deid-log: ${fullPathToLogFile}";

        
    if (! -d $logDir ) {
        mkpath($logDir, { verbose => 0, mode => 0700 }) or die("Cannot create output directory $logDir");
    }

}

my ($configBaseName, $configDir, $configSuffix) = fileparse($outputConfigFile, ".yaml");

if (!($configSuffix && $configSuffix eq ".yaml")) {
    $configSuffix = ".yaml";
}

if (! -d $configDir ) {
    mkpath($configDir, { verbose => 0 }) or die("Cannot create output directory $configDir");
}

my $fullPathToConfigFile = "${configDir}${configBaseName}${configSuffix}";

open(my $configFH, ">", "$fullPathToConfigFile");

my $configPreamble = qq{#
# Start with the empty profile
profile: none

# Example usage with CLI:
#   fw import dicom /path/to/dicomDir aGroup aProject \\
#    --subject subjectID \\
#    --session sessionID \\
#    --output-folder /path/to/testOutput \\
#    --profile PennBrainCenter_FlywheelDeIdConfig.yaml

# Log de-identification actions that were taken (before/after values)
# This file will contain PHI, secure appropriately
${deIDLogString}

# Configuration for dicom de-identification
dicom:

#
# Example config options here taken from Flywheel documentation page
#
#  # Set patient age from date of birth
#  patient-age-from-birthdate: true
#
#  # Set patient age units as Years
#  patient-age-units: Y

  # Entries under here are generated from a script
  fields:

};

print $configFH $configPreamble;

my $indentNumber = 4;

my $indentWS = join("", " " x $indentNumber);


if (-f $replaceCSV) {

    my $hashRef = getTagsKeywordsReplacements($replaceCSV);
    
    # tag => (keyword, replacement)
    my %replaceTags = %$hashRef;
    
    foreach my $tag ( sort(keys(%replaceTags)) ) {
        my ($keyword, $replacementText) = @{$replaceTags{$tag}};

        # Add a comment
        print $configFH $indentWS . "# $tag \n";
        print $configFH $indentWS . "- name: ${keyword}\n";
        print $configFH $indentWS . "  replace-with: ${replacementText}\n";
    }

    print $configFH "\n";
}


if (-f $removeCSV) {
    my $hashRef = getTagsAndKeywords($removeCSV);
        
    # tag => keyword
    my %removeTags = %$hashRef;

    foreach my $tag ( sort(keys(%removeTags)) ) {
        my $keyword = $removeTags{$tag};

        # Add a comment
        print $configFH $indentWS . "# $tag \n";
        print $configFH $indentWS . "- name: ${keyword}\n";
        print $configFH $indentWS . "  remove: true\n";
    }

    print $configFH "\n";
}


if (-f $emptyCSV) {
    
    my $hashRef = getTagsAndKeywords($emptyCSV);
    
    # tag => (keyword, replacement)
    my %emptyTags = %$hashRef;
    
    foreach my $tag ( sort(keys(%emptyTags)) ) {
        my $keyword = $emptyTags{$tag};
        
        # Add a comment
        print $configFH $indentWS . "# $tag \n";
        print $configFH $indentWS . "- name: ${keyword}\n";
        print $configFH $indentWS . "  replace-with: ''\n";
    }

    print $configFH "\n";
}

close($configFH);


sub getTagsAndKeywords {

    my $tagFile = $_[0];

    my $csv = Text::CSV->new({ sep_char => ',' });

    open(my $fh, "<", $tagFile) or die("Could not open '$tagFile' $!\n");

    my %tagsToProcess;

    my $header = <$fh>;

    chomp($header);

    if (! $header eq "Tag,Keyword") {
        die("Required column names \"Tag,Keyword\" in $tagFile\n");
    }
    
    while (my $line = <$fh>) {
        chomp $line;
 
        if ($csv->parse($line)) {
 
            my @fields = $csv->fields();

            if (scalar(@fields) != 2) {
                die("Wrong format in file $tagFile\n");
            }

            $tagsToProcess{$fields[0]} = $fields[1];
            
        } else {
            die("Line could not be parsed: $line\n");
        }
    }

    close($fh);

    return \%tagsToProcess;
}

sub getTagsKeywordsReplacements {

    my $replaceFile = $_[0];

    my $csv = Text::CSV->new({ sep_char => ',' });

    open(my $fh, "<", $replaceFile) or die("Could not open '$replaceFile' $!\n");

    my %tagsToReplace;

    my $header = <$fh>;
    
    chomp($header);

    if (! $header eq "Tag,Keyword,Replacement") {
        die("Required column names \"Tag,Keyword\" in $replaceFile\n");
    }

    while (my $line = <$fh>) {
        chomp $line;
 
        if ($csv->parse($line)) {
 
            my @fields = $csv->fields();

            if (scalar(@fields) != 3) {
                die("Wrong format in file $replaceFile\n");
            }

            # Keyword plus the replacement text
            my @keywordReplace = ($fields[1], $fields[2]);

            $tagsToReplace{$fields[0]} = \@keywordReplace;
            
        } else {
            die("Line could not be parsed: $line\n");
        }
    }

    close($fh);

    return \%tagsToReplace;
}
