#!/usr/bin/perl

#TBD: get nodes and edges from user
#Globals
@nodes=('R1','R2','R3','R4','R5','R6','R7','R8','R9','R10','B1','B2','B3','B4','B5','G1','G2','G3','G4','G5','T1','T2','T3','T4','T5');
@edges=('R1-R2','R2-R1','R2-R3','R3-R2','R3-R4','R4-R3','R4-R5','R5-R4','R5-R6','R6-R5','R6-R7','R7-R6','R7-R8','R8-R7','R8-R9','R9-R8','R9-R10','R10-R9','R10-R1','R1-R10','B1-B2','B2-B1','B2-B3','B3-B2','B3-B4','B4-B3','B4-B5','B5-B4','G1-G2','G2-G1','G2-G3','G3-G2','G3-G4','G4-G3','G4-G5','G5-G4','T1-R2','R2-T1','T1-B2','B2-T1','T2-B3','B3-T2','T2-R10','R10-T2','T3-R5','R5-T3','T3-G5','G5-T3','T4-R9','R9-T4','T4-G3','G3-T4','T5-B4','B4-T5','T5-G2','G2-T5');
%adjacency_matrix;
@unvisited;
%distance;
%previous;
@neighbour_array;
@neighbours;
$current_node="";
$infinity = "inf";


$nodes_size=@nodes;
$edges_size=@edges;

$optionId = $ARGV[0];

if($optionId eq "-s"){
    if($#ARGV != 2){
        print "Not enough params\n";
        showUsage();
    }
    else{
      find_shortest_path($ARGV[1],$ARGV[2]);
    }
}
elsif($optionId eq "-p"){
    load_matrix();
    print_matrix();
}

else{
	print "Incorrect parameters were supplied\n";
	showUsage();
}

sub showUsage
{
	print "\nUsage: \n";
    print " Q1. Print matrix: perl hopstopo.pl -p\n";
	print " Q2. To find the shortest path: perl hopstop.pl -s <src> <dst>\n";
	die "";	
}

# prints adjacency_matrix
sub print_matrix
{
    #loops through the two dimensional matrix andd displays the adjacency_matrix
    foreach $node1 (@nodes){
        foreach $node2 (@nodes){
            print $adjacency_matrix{$node1}{$node2}."  ";
        }
    print "\n";
    }
}

# Q1 Write a Perl routine to create adjacency matrix data structure.
# creates the matrix object. Initialy, each element in the matrix will be
# a zero(indices are the same) or 'inf'(stands for infinity)
# load_matrix function actuallys loads data into the matrix
sub create_matrix
{
    foreach $node1 (@nodes){
        foreach $node2 (@nodes){
            if($node1 eq $node2){
                $adjacency_matrix{$node1}{$node2}=0;
            }
            else{
                $adjacency_matrix{$node1}{$node2}=$infinity;
            }
        }
    } 
    return %adjacency_matrix;      
}
# Q1 Write a Perl routine to load the graphed data to the data structure
# loads data into the object
sub load_matrix
{
    %adjacency_matrix = create_matrix();
    foreach $edge (@edges){
        my @ns = split('-', $edge);
        $size=@ns;
        if($size != 2 || not $ns[0] ~~ @nodes || not $ns[1] ~~ @nodes){
            print "incorrect edge format: ".$edge."\n";
            next;
        }
        else{
            $adjacency_matrix{$ns[0]}{$ns[1]}=1;
        }            
    }
    #print_matrix();
}

#get neighbouring nodes of the 'current' node
sub get_neighbours{
    @neighbours=[];
    foreach $n (@nodes){
        $d = $adjacency_matrix{$current}{$n};
        # if the cell value is infinity or zero, skip it.
        # if the node is already visited skip it.
        if($d eq $infinity || $d eq 0 || (not $n ~~ @unvisited)){
            next;
        }
        else{
            push(@neighbours,$n);
        }
    }
    return @neighbours;
}

# get the distance of the closest unvisited node
sub get_least_distance{
    $l=100000;
    while (($key, $value) = each(%distance)){
        if($value ne $infinity && $value < $l){
            $l = $value;
        }    
    }
    if($l eq 10000){$l = $infinity}
    return $l;
}

#get the closest element
sub get_least_element(){
    $least="";
    $temp = 10000000;
    foreach $n (@unvisited){
        if(($distance{$n} ne $infinity) && ($distance{$n} ne 0) && ($distance{$n} <= $temp)){
            $least = $n;
            $temp = $distance{$n};
            #print "least is $n\n";
        }
    }
    return $least;
}

# Q2 Write a program in Perl to that would find the route with minimal number of stations passed (count a transfer point as one station passed) between any two stations in HopStop city.
#implements Djikstra's algorithm
sub find_shortest_path{
    load_matrix();
    %previous={};
    %distance={};
	$src = $_[0];
	$dst = $_[1];

    if(not $src ~~ @nodes){
        die "source node not in graph\n"
    }
    elsif(not $dst ~~ @nodes){
        die "destination node not in graph\n"
    }


    @unvisited;  
    #prepare the unvisited list
    foreach $node (@nodes){
        if($node eq $src){
            $distance{$node}=0;
        }
        else{
            $distance{$node}=$infinity;
        }
        push(@unvisited,$node);
    }
    
    $current = $src;
    while($current ne ""){
        @neighbours =  get_neighbours();
        
        foreach $n (@neighbours){
            if (($distance{$n} eq $infinity) || ($distance{$n} > ($distance{$current} + $adjacency_matrix{$current}{$n})) ) {
                $cc = $distance{$n};
	            $distance{$n} = $distance{$current} + $adjacency_matrix{$current}{$n};
                $previous{$n}=$current;
	        }
        }
        # remove the current node from the unvisited list. It is not longer unvisited
        $index = 0;
        $index++ until $unvisited[$index] eq "$current";
        splice(@unvisited, $index, 1);
        $least_distance = get_least_distance();

        if(not $dst ~~ @unvisited || $least_distance eq $infinity){
            last;
        }
        else{
            # get the next node that has the least distance from source node
            $current=get_least_element();
        }
    }
    print "The output contains additional paths. I did not have time to remove them. To read the output, search for the line that starts with $dst - your destination. \n For ex, lets say our dst is G5. Then look for a line in the output that starts with G5. If there is a valid path, then there would be a line(only one) that starts with 'G5 from ..'. Lets say we find a line that says 'G5 from T1'. Now look for a line that starts with 'T1 from ...'. I guess you shoudl get the idea now - you'll be able to traceback to the source\n";
    while (($d, $s) = each(%previous)){
        print $d." from ".$s."\n";
    }

}






