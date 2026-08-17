{
	description = "Vercel CLI (native binary)";

	inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

	outputs = { self, nixpkgs }: let
	version = "59.1.3";

	platforms = {
		"x86_64-linux" = {
			pkg = "vc-native-linux-x64";
			hash = "sha512-ihohS24kl4zBoAKH/9Rs7jMgXC1CGt7XyeD1yPgIBA3op/BJE9o02FGJst+HSpsSusK0mY09eDvQtdURtu3dog==";
		};
		"aarch64-linux" = {
			pkg = "vc-native-linux-arm64";
			hash = "sha512-1S3g6o8GnI23eQUb4btmmu8H5YzIggZo0rwSkqLqWdCpHT0CMfN/d/A73YE1kkEwcNfXgcnO5HT8d3Bti4AIdw==";
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
