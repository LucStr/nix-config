{ buildDotnetGlobalTool, lib }:

buildDotnetGlobalTool {
  pname = "jb";
  nugetName = "JetBrains.ReSharper.GlobalTools";
  version = "2023.2.3";

  nugetSha256 = "sha256-E1GoXNeu8IqKf0CCTTo+fTNVSkDg23i4nX5RHmpMFis=";

  meta = with lib; {
    homepage = "http://www.jetbrains.com/resharper/features/command-line.html";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
