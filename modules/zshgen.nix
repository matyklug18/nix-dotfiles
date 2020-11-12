{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.zshgen;
in {
	options.programs.zshgen = {
		enable = mkEnableOption ".zshrc generator";

		plugins = mkOption {
			type = types.listOf types.str;
			default = [];		
		};

		p10k = {
			enable = mkEnableOption "p10k";
		};

		shellAliases = mkOption {
			type = types.attrs;
			default = {};
		};
	};
	config = mkIf cfg.enable {
		programs.zsh = { 
			enable = true;
			enableCompletion = false;
			shellAliases = cfg.shellAliases;
			initExtra = "
				source ~/.config/zsh/.zinit/bin/zinit.zsh

				if [[ ! -f $HOME/.config/zsh/.zinit/bin/zinit.zsh ]]; then
						print -P \"%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f\"
						command mkdir -p \"$HOME/.config/zsh/.zinit\" && command chmod g-rwX \"$HOME/.config/zsh/.zinit\"
						command git clone https://github.com/zdharma/zinit \"$HOME/.config/zsh/.zinit/bin\" && \
								print -P \"%F{33}▓▒░ %F{34}Installation successful.%f%b\" || \
								print -P \"%F{160}▓▒░ The clone has failed.%f%b\"
				fi

				if [[ ! -f $HOME/.p10k.zsh ]]; then
					expect -c '
					set timeout -1
					spawn zsh -f
					send -- \"INSIDE_P10K=yes\\r\"
					send -- \"source ~/.zshrc\\r\"
					send -- \"p10k configure\\r\"
					send -- \"yyyy3121342214121y1y\\r\"
					send -- \"touch exit.tmp\\r\"
					send -- \"exit\\r\"
					expect eof
					' & while true; do; if [[ -t \"exit.tmp\" ]]; then; kill $1; rm exit.tmp; fi; done;
				fi;

				${
					if cfg.p10k.enable then
						"

						zinit ice depth=1; zinit light romkatv/powerlevel10k
						if [[ -r \"\${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\" ]]; then
							source \"\${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\"    
						fi

						# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
						[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
						"
					else ""
				}

				${
					builtins.concatStringsSep "\n" (lib.forEach cfg.plugins ( txt: "zinit wait lucid for \\\n${txt}" ))
				}
			";
		};
	};
}
