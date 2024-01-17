{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v2.1 (eol)
{
  aspnetcore_2_1 = buildAspNetCore {
    version = "2.1.30";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/d6040f80-8343-4771-9c02-dbc9a35ac88a/68e74e6e46cf36fa1a50f68af6831d6d/aspnetcore-runtime-2.1.30-linux-x64.tar.gz";
        sha512  = "60f65e2e37bb9af54f809ef0f4fe814c4c0dd9c969dea1aa81e94c0dc2433c5011cde39118196310ffac4e248b24924a2c154534194e70a8cdae40dfc81fe3d1";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/a22ee713-db35-4232-a968-56a9da281ad0/d793935b7c0d1543bc1beb2931da4449/aspnetcore-runtime-2.1.30-osx-x64.tar.gz";
        sha512  = "ecdc1a055bd2352ae59394a7f9adf21f119b9f772a05da84feedc2e1c20c50acb09afc53d111e8193dc0fcd3a02dbe08eec01389eada09fb4c5b4f977d40d5a8";
      };
    };
  };

  runtime_2_1 = buildNetRuntime {
    version = "2.1.30";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/84904da8-51ea-4ff2-b816-a2a16442eb7c/ebc16d3a87af8002cd2b2ea63a351db1/dotnet-runtime-2.1.30-linux-x64.tar.gz";
        sha512  = "b7433c9f03f7363759a044b50d8cca9486cfe402fdf62163696ba6a172e9839a140553e3d3298bb75c89dda2f6f4bec294847411f3fc2796fa4881a2b01a7178";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/1b63625d-531e-44f0-9daf-4a14d0e286d4/99d79b3c2365c7b9cea2199e38b54790/dotnet-runtime-2.1.30-linux-arm64.tar.gz";
        sha512  = "41aef859a9065b6adc1df04819b7079b6385c370a9c603f351c0826773ee43d52ecb565191a3ae5dddb043fde6e8f47c244e896360055f8271c63ecb719c302f";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/4b5b8df3-10f3-4319-9e47-b9b8983121ce/1c49701b761db6534d68f0bf75748d29/dotnet-runtime-2.1.30-osx-x64.tar.gz";
        sha512  = "548f5569179c64ed6e8f6976c775470f25cab210aff18ef18de6d35152bbe1bee23e58a6d366094bebcd77c70aec449a613d29fe1e076cbb6ed62178ba52d3f3";
      };
    };
  };

  sdk_2_1 = buildNetSdk {
    version = "2.1.818";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/5797d98a-8faf-472d-925c-931ac542d3c8/e48942da88f4d9d653a7b5c0790e7724/dotnet-sdk-2.1.818-linux-x64.tar.gz";
        sha512  = "0975301378d1238e55285d37aed4ab10df242e0884c0e3bb2eaf2e96af7bf6d554f5df1e653abddabf23ed8f1ea1665c452de42ad912ca84cd71760171416ecd";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/04bec57b-d2a9-46b0-8c97-848558818000/1e67e2407b0518c9d2a692ba1fc99b22/dotnet-sdk-2.1.818-linux-arm64.tar.gz";
        sha512  = "4a8dfb282ba5c8b286e3b09c100a738a43df41fef371d0f6e7b3341aafb8ff00436658d1139175ec0a545e49a15aedda0efc6a4b97b7324c3cef5cdab8ff0451";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/fc42fd66-af16-4164-8bea-b050f279172d/aac481e88a7cb695ee3d0333fd96bb99/dotnet-sdk-2.1.818-osx-x64.tar.gz";
        sha512  = "0a3ed2cf18eda2bf9dab1be7a389fb7d7e328429284bd267a8f15d53e369e57e260c0f9766e911226e3b8f7f78dd4717c808fe98c8ff1e6f673dce30a4ec6ce6";
      };
    };
    packages = { fetchNuGet }: [


    ];
  };
}
