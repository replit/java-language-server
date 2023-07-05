# This was modified from https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/development/tools/java/java-language-server/default.nix
{ lib
, stdenv
, fetchFromGitHub
, jdk
, maven
, runtimeShell
, makeWrapper
}:

let
  platform =
    if stdenv.isLinux then "linux"
    else if stdenv.isDarwin then "mac"
    else if stdenv.isWindows then "windows"
    else throw "unsupported platform";
in
stdenv.mkDerivation rec {
  pname = "java-language-server";
  version = "0.2.38";

  src = ./.;

  fetchedMavenDeps = stdenv.mkDerivation {
    name = "java-language-server-${version}-maven-deps";
    inherit src;
    buildInputs = [ maven ];

    buildPhase = ''
      runHook preBuild

      mvn package -Dmaven.repo.local=$out -DskipTests -e

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      find $out -type f \
        -name \*.lastUpdated -or \
        -name resolver-status.properties -or \
        -name _remote.repositories \
        -delete

      runHook postInstall
    '';

    dontFixup = true;
    dontConfigure = true;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-YqYXtFeDByhqkPytkRakj85pkoi5UKD9/SkSqSJ1XBA=";
  };


  nativeBuildInputs = [ maven jdk makeWrapper ];

  dontConfigure = true;
  buildPhase = ''
    runHook preBuild

    jlink \
      ${lib.optionalString (!stdenv.isDarwin) "--module-path './jdks/${platform}/jdk-13/jmods'"} \
      --add-modules java.base,java.compiler,java.logging,java.sql,java.xml,jdk.compiler,jdk.jdi,jdk.unsupported,jdk.zipfs \
      --output dist/${platform} \
      --no-header-files \
      --no-man-pages \
      --compress 2

    mvn package --offline -Dmaven.repo.local=${fetchedMavenDeps} -DskipTests

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java/java-language-server
    cp -r dist/classpath dist/*${platform}* $out/share/java/java-language-server

    # a link is not used as lang_server_${platform}.sh makes use of "dirname $0" to access other files
    makeWrapper $out/share/java/java-language-server/lang_server_${platform}.sh $out/bin/java-language-server

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Java language server based on v3.0 of the protocol and implemented using the Java compiler API";
    homepage = "https://github.com/replit/java-language-server";
    license = licenses.mit;
    maintainers = with maintainers; [ hqurve ];
    platforms = platforms.all;
  };
}
