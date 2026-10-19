{
	description = "Vercel CLI (native binary)";

	inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

	outputs = { self, nixpkgs }: let
	version = "64.5.0";

	platforms = {
		"x86_64-linux" = {
			pkg = "vc-native-linux-x64";
			hash = "sha512-M8v1uTdQNibwKzwOYpM1PI5uOJHsjkR/xlbKZvbYqZl3KNvM8zsIE1kxBIzSbHcJ89iVYuJRgGw9hOMJOaF0IQ==";
		};
		"aarch64-linux" = {
			pkg = "vc-native-linux-arm64";
			hash = "sha512-fCUroTSffE7ZvYOzgSFVy7UX3U8kchx0YHBp4DXsAQ7p65z55z8x3C7E28Pg7PEj12GlGQNs59D0oD38g67fyg==";
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
