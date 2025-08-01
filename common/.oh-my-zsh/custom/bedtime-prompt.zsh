# Bedtime reminder in shell prompt

bedtime_prompt() {
    # Get severity info from central script
    local result=$($HOME/.config/bedtime/time-status.sh terminal)
    
    if [[ -n "$result" ]]; then
        # Parse the result format: "color:emoji text"
        local color="${result%%:*}"
        local content="${result#*:}"
        
        case "$color" in
            yellow)
                echo "%{$fg_bold[yellow]%}[$content]%{$reset_color%} "
                ;;
            red)
                echo "%{$fg_bold[red]%}[$content]%{$reset_color%} "
                ;;
        esac
    fi
}

# Add to prompt - this works with most themes
PROMPT='$(bedtime_prompt)'$PROMPT

# For agnoster theme specifically, we need to add it differently
if [[ "$ZSH_THEME" == "agnoster" ]]; then
    # Define our bedtime prompt segment
    prompt_bedtime() {
        # Get severity info from central script
        local severity=$($HOME/.config/bedtime/time-status.sh severity)
        local emoji=$($HOME/.config/bedtime/time-status.sh emoji)
        
        case "$severity" in
            1)  # Wind down
                prompt_segment yellow black "$emoji"
                ;;
            2)  # Go to bed
                prompt_segment red white "$emoji BED!"
                ;;
            3)  # Way past bedtime
                prompt_segment red white "$emoji SLEEP!"
                ;;
        esac
    }
    
    # Override the original build_prompt function
    # Note: agnoster's build_prompt is sourced after custom files,
    # so we need to ensure our function takes precedence
    
    # Create our new build_prompt
    build_prompt() {
        RETVAL=$?
        prompt_status
        prompt_virtualenv
        prompt_aws
        prompt_bedtime  # Add bedtime check here
        prompt_context
        prompt_dir
        prompt_git
        prompt_bzr
        prompt_hg
        prompt_end
    }
fi