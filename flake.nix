{
	description = "Vercel CLI (native binary)";

	inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

	outputs = { self, nixpkgs }: let
	version = "63.1.2";

	platforms = {
		"x86_64-linux" = {
			pkg = "vc-native-linux-x64";
			hash = "sha512-caQBi4OUQzwUL65dnCkTvQn+RP8VA7WbygwKEZj8KJLXyIatzrIfvj/YcPaAv5dlZJaoChzg8VmLaUOVsJ5Yxg==";
		};
		"aarch64-linux" = {
			pkg = "vc-native-linux-arm64";
			hash = "sha512-UkqNIQEJGYAsJJ07jVWoUhCm+15DGq4bfz2ZBpXjImw61l/rCXW9qoY1j0JzJhS+Wt9JWoi/SEDsH8LIxuZWxg==";
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
