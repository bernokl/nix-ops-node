# A common `std` idiom is to place all buildables for a cell in a `apps.nix`
# cell block. This is not required, and you can name this cell block anything
# that makes sense for your project.
#
# This cell block is used to define how our example application is built.
# Ultimately, this means it produces a nix derivation that, when evalulated,
# produces our binary.

# The function arguments shown here are universal to all cell blocks. We are
# provided with the inputs from our flake and a `cell` attribute which refers
# to the parent cell this block falls under. Note that the inputs are
# "desystematized" and are not in the same format as the `inputs` attribute in
# the flake. This is a key benefit afforded by `std`.
{ inputs
, cell
}:
let
  # The `inputs` attribute allows us to access all of our flake inputs.
  #  inherit (inputs) nixpkgs std;
  inherit (inputs) nixpkgs;
  inherit (inputs.std) std lib;
  inherit (inputs.nix-cache.packages) nix-serve;


  # This is a common idiom for combining lib with builtins.
  l = nixpkgs.lib // builtins;

  debug = true;
  log = reason: drv: l.debug.traceSeqN 1 "DEBUG {$reason}: ${drv}" drv;

in
{
  ## This does the same as inherit (inputs.nix-cache.packages) nix-serve; combined with the entire default block
  serve = log "TESTIN APP" (inputs.nix-cache.packages.nix-serve);
  # We can think of this attribute set as what would normally be contained under
  # `outputs.packages` in our flake.nix. In this case, we're defining a default
  # package which contains a derivation for building our binary.
  default = log "SERV APP" (nixpkgs.writeShellApplication   { 
      name = "serveit";
      runtimeInputs = [nix-serve];
      text = ''
      nix-serve --port 8080
      '';
   });
}

