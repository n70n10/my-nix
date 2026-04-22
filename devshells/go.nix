{ pkgs }:

pkgs.mkShell {
  name = "go-dev";

  packages = with pkgs; [
    go
    gopls           # LSP
    gotools         # goimports, godoc, etc.
    go-tools        # staticcheck
    delve           # debugger
    golangci-lint
    gomodifytags
    impl            # interface stub generator
    gotests         # test boilerplate generator
    air             # live reload
  ];

  shellHook = ''
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
    echo "Go $(go version | awk '{print $3}') devshell ready"
  '';
}
