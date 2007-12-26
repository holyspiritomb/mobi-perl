package MobiPerl::LinksInfo;

use FindBin qw($RealBin);
use lib "$RealBin";

use strict;

###use MobiPerl::Util;
##use Data::Dumper;

sub new {
    my $this = shift;
    my $class = ref($this) || $this;
    my $obj = bless {
	LINKEXISTS => {},
	RECORDINDEX => 0,
	RECORDTOIMAGEFILE => {},
	@_
    }, $class;
    return $obj;
}

sub link_exists {
    my $self = shift;    
    return $self->{LINKEXISTS};
}

sub add_image_link {
    my $self = shift;
    my $image = shift;
##    print STDERR "ADD_IMAGE_LINK: $image\n";
    $self->{RECORDINDEX}++;
    $self->{RECORDTOIMAGEFILE}->{$self->get_record_index ()} = $image;
}

sub get_record_index {
    my $self = shift;    
    return $self->{RECORDINDEX};
}

sub get_image_file {
    my $self = shift;    
    my $val = shift;
    return $self->{RECORDTOIMAGEFILE}->{$val};
}

sub get_n_images {
    my $self = shift;
    my $res = keys %{$self->{RECORDTOIMAGEFILE}};
    return $res;
}



sub check_for_links {
    my $self = shift;
    my $html = shift;
    for (@{$html->extract_links('a', 'img')}) {
	my($link, $element, $attr, $tag) = @$_;
	next if ($link =~ /http/);
	next if ($link =~ /mailto/);
	next if ($link =~ /www/);
#	print STDERR "LINK: $tag $link $attr at ", $element->address(), " ";
	if ($tag eq "a") {
	    my $filename = $element->as_trimmed_text ();
##	    print STDERR "LINKEXISTS $filename -> $link - ";
	    #
	    # Remove possible prefix file name in link
	    #
	    
	    $link =~ s/^.*\#//;
##	    print STDERR "$link\n";

	    $element->attr("href", "\#$link");
	    $self->{LINKEXISTS}->{$link} = 1;
	    next;
	}
	if ($tag eq "img") {
	    my $src = $element->attr("src");
	    $element->attr("src", undef);
	    $self->{RECORDINDEX}++;
	    #
	    # Does not work for more than 9 images
	    #
	    $element->attr("recindex", sprintf ("%05d", $self->{RECORDINDEX}));
	    $self->{RECORDTOIMAGEFILE}->{$self->{RECORDINDEX}} = $src;
	    next;
	}
	print STDERR "LINK: $tag $link $attr at ", $element->address(), " ";
#	print STDERR $element->as_HTML;
    }
}

return 1;
