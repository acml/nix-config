let
  inherit (builtins) attrNames attrValues filter mapAttrs listToAttrs;

  bemeurer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIQgTWfmR/Z4Szahx/uahdPqvEP/e/KQ1dKUYLenLuY2";

  hosts =
    let
      all = import ./nix/hosts.nix;
      withPubkey = filter (a: all.${a} ? pubkey) (attrNames all);
    in
    listToAttrs (map (name: { inherit name; value = all.${name}.pubkey; }) withPubkey);

  secrets = with hosts; {
    "hardware/nixos-aarch64-builder/key.age" = [ jung riemann spinoza ];
    "services/acme.age" = [ jung plato riemann ];
    "services/oauth2.age" = [ jung plato riemann ];
    "services/pihole.age" = [ ];
    "services/github-runner.age" = [ jung ];
    "users/bemeurer/password.age" = attrValues hosts;
  };

  secrets' = mapAttrs (_: v: { publicKeys = [ bemeurer ] ++ v; }) secrets;

  allHostSecret = secretName:
    listToAttrs (
      map
        (host: {
          name = "hosts/${host}/${secretName}.age";
          value.publicKeys = [ bemeurer hosts.${host} ];
        })
        (attrNames hosts)
    );
in
secrets' // allHostSecret "password"
