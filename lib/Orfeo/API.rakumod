unit class Orfeo::API;

use HTTP::Tiny;
use JSON::Tiny;

has Str $.endpoint = 'http://orfeolang.com/api';
has Int $.version = 1;

has %!headers = (
    "Content-Type" => "application/json",
    "Accept" => "version=$!version",
);

has $!http = HTTP::Tiny.new(:default-headers(%!headers));

method !add-payload-from-content ($res) {
    if $res<content> {
        $res<payload> = from-json($res<content>.decode);
    }
    return $res;
}

method !get (Str $uri) {
    my $res = $!http.get($!endpoint ~ $uri);
    return self!add-payload-from-content($res);
}

method versions  { self!get('/versions') }
method compilers { self!get('/compilers') }

method compile (Str :$program, Str :$compiler) {
    my %payload;
    %payload<program> = $program if $program.defined;
    %payload<compiler> = $compiler if $compiler.defined;
    my $res = $!http.post(
        $!endpoint ~ '/compile',
        :content(to-json(%payload))
    );
    return self!add-payload-from-content($res);
}
