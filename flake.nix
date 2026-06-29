{
	description = "Vercel CLI (native binary)";

	inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

	outputs = { self, nixpkgs }: let
	version = "54.14.0";

	platforms = {
		"x86_64-linux" = {
			pkg = "vc-native-linux-x64";
			hash = "sha512-xiZBsvoWZBw/qkqFZjNp8bAdSfrUFWdGcLaK4xWByJw4nb4Rvc5lNMyjDNfAUzBnrtN1ad91qTCJIVEh5t1+ow==";
		};
		"aarch64-linux" = {
			pkg = "vc-native-linux-arm64";
			hash = "sha512-uKx0HGNyk1YP8y/C3E4+1N0ELli8INrEx08kQO7muLHfFAj9aSlryJnBDSJ6ePEjVY4XyoZezJtk631Z4kA4yw==";
		};
	};

	forAllSystems = nixpkgs.lib.genAttrs (builtins.attrNames platforms);
	in {
		packages = forAllSystems (system: let
		pkgs = nixpkgs.legacyPackages.${system};
		meta = platforms.${system};
		in {
			default = pkgs.stdenv.mkDerivation {
				pname = "vercel";
				inherit version;

				src = pkgs.fetchurl {
					url = "https://registry.npmjs.org/@vercel/${meta.pkg}/-/${meta.pkg}-${version}.tgz";
					hash = meta.hash;
				};

				nativeBuildInputs = [ pkgs.autoPatchelfHook ];
				buildInputs = [ pkgs.stdenv.cc.cc.lib ];

				installPhase = ''
				mkdir -p $out/bin
				cp bin/vercel $out/bin/vercel
				chmod +x $out/bin/vercel
				'';

				meta = {
					description = "The command-line interface for Vercel (native binary)";
					homepage = "https://vercel.com";
					license = pkgs.lib.licenses.asl20;
					mainProgram = "vercel";
					platforms = builtins.attrNames platforms;
				};
			};
		}
		);
	};
}
