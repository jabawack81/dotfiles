# Bedtime reminder in shell prompt

bedtime_prompt() {
    local hour=$(date +%H)
    local day=$(date +%u)  # 1=Monday, 7=Sunday
    
    # Only on school nights (Sunday-Thursday nights)
    if [[ $day -ge 1 && $day -le 4 ]] || [[ $day -eq 7 ]]; then
        if [[ $hour -eq 22 ]]; then
            echo "%{$fg_bold[yellow]%}[🌙 Wind down]%{$reset_color%} "
        elif [[ $hour -eq 23 ]]; then
            echo "%{$fg_bold[red]%}[😠 GO TO BED!]%{$reset_color%} "
        elif [[ $hour -ge 0 && $hour -lt 6 ]]; then
            echo "%{$fg_bold[red]%}[💀 SLEEP NOW!]%{$reset_color%} "
        fi
    fi
}

# Add to prompt - this works with most themes
PROMPT='$(bedtime_prompt)'$PROMPT

# For agnoster theme specifically, we need to add it differently
if [[ "$ZSH_THEME" == "agnoster" ]]; then
    # Agnoster uses a different prompt building method
    prompt_bedtime() {
        local hour=$(date +%H)
        local day=$(date +%u)
        
        if [[ $day -ge 1 && $day -le 4 ]] || [[ $day -eq 7 ]]; then
            if [[ $hour -eq 22 ]]; then
                prompt_segment yellow black "🌙"
            elif [[ $hour -eq 23 ]]; then
                prompt_segment red white "😠 BED!"
            elif [[ $hour -ge 0 && $hour -lt 6 ]]; then
                prompt_segment red white "💀 SLEEP!"
            fi
        fi
    }
    
    # Add to agnoster's prompt builders
    build_prompt() {
        RETVAL=$?
        prompt_status
        prompt_virtualenv
        prompt_aws
        prompt_bedtime  # Add bedtime check
        prompt_context
        prompt_dir
        prompt_git
        prompt_bzr
        prompt_hg
        prompt_end
    }
fi