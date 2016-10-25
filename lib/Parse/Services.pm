package Parse::Services;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(parse_services);

our %SPEC;

$SPEC{parse_hosts} = {
    v => 1.1,
    summary => 'Parse /etc/hosts',
    args => {
        content => {
            summary => 'Content of /etc/services file',
            description => <<'_',

Optional. Will attempt to read `/etc/services` from filesystem if not specified.

_
            schema => 'str*',
        },
    },
    examples => [
    ],
};
sub parse_services {
    my %args = @_;

    my $content = $args{content};
    unless (defined $content) {
        open my($fh), "<", "/etc/services"
            or return [500, "Can't read /etc/services: $!"];
        local $/;
        $content = <$fh>;
    }

    my @res;
    for my $line (split /^/, $content) {
        $line =~ s/#.*//;
        next unless $line =~ /\S/;
        chomp $line;
        my ($name, $port_proto, @aliases) = split /\s+/, $line;
        my ($port, $proto) = split m!/!, $port_proto;
        push @res, {
            name  => $name,
            port  => $port,
            proto => $proto,
            aliases => \@aliases,
        };
    }
    [200, "OK", \@res];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use Parse::Services qw(parse_services);
 my $res = parse_services();


=head1 SEE ALSO

L<parse-services> from L<App::ParseServices>, CLI script.
