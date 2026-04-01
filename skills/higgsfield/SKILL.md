---
name: higgsfield
description: Generate images and videos via Higgsfield AI (higgsfield.ai) using OpenClaw browser with agent's own browser profile
argument-hint: "[image|video] prompt"
allowed-tools: Bash(sleep*), Bash(ssh*), Bash(*/env.sh*)
user-invocable: true
---

# Higgsfield Generation

Read the `/browser` skill first for general browser automation guidelines.

## Input

`$ARGUMENTS` = mode + prompt. First word is `image` or `video`, rest is the prompt. Default: `image`.

## Modes

| Mode | URL |
|------|-----|
| `image` | `https://higgsfield.ai/image/nano_banana_2` |
| `video` | `https://higgsfield.ai/video` |

## Method: OpenClaw Browser (with agent profile)

Every command MUST include `--browser-profile claude`. This ensures tab isolation across agents and preserves login sessions.

### Environment

```bash
!`${CLAUDE_SKILL_DIR}/env.sh block`
```

All commands below use the SSH and OC variables from the environment block. Append `--browser-profile claude` to every `$OC` command.

### Submission Workflow

```bash
# 1. Open generation page in NEW TAB (never navigate!)
TARGET=$($SSH "$OC open 'https://higgsfield.ai/image/nano_banana_2' --browser-profile claude")
# Parse target ID from output (second line), e.g. TARGET=5AC6D2B8...

# 2. Focus your tab
$SSH "$OC focus <targetId> --browser-profile claude"

# 3. Snapshot to get element refs
$SSH "$OC snapshot --labels --browser-profile claude"

# 4. Dismiss any promo dialogs (press Escape if a dialog blocks the page)
$SSH "$OC press Escape --browser-profile claude"
$SSH "$OC snapshot --labels --browser-profile claude"

# 5. Set aspect ratio (MUST do before typing prompt)
#    Click the current aspect button -> snapshot -> click desired option
$SSH "$OC click <aspect-btn-ref> --browser-profile claude"
$SSH "$OC snapshot --labels --browser-profile claude"   # Find the option refs
$SSH "$OC click <option-ref> --browser-profile claude"  # e.g. 16:9, 9:16, 1:1

# 6. Click textbox, select all, type prompt
$SSH "$OC click <textbox-ref> --browser-profile claude"
$SSH "$OC press 'Meta+a' --browser-profile claude"
$SSH "$OC type <textbox-ref> 'prompt text here' --browser-profile claude"

# 7. Re-snapshot (refs change after typing) and click Generate
$SSH "$OC snapshot --labels --browser-profile claude"
$SSH "$OC click <generate-ref> --browser-profile claude"

# 8. Wait for generation (30-60s for images, 60-180s for video)
sleep 45
$SSH "$OC snapshot --labels --browser-profile claude"
# Look for completed images in history (no more "Generating" text)

# 9. Close tab when done
$SSH "$OC close <targetId> --browser-profile claude"
```

### Downloading Results

After generation completes, images appear in the History panel. To download:

1. Click on a generated image in history to open the detail view
2. Snapshot to find the download button ref
3. Use `openclaw browser download <ref>` to save the image

Alternatively, right-click save or screenshot the results.

### Important Quirks

- **Promo dialogs** -- Higgsfield shows promotional popups on page load. Press Escape to dismiss, then re-snapshot.
- **Aspect ratio resets** -- Higgsfield may reset aspect ratio between generations. Always verify the current aspect before submitting.
- **Refs change after every action** -- always re-snapshot before clicking if you've typed or navigated.
- **Page navigation** -- clicking some elements navigates away. If this happens, open a fresh tab.
- **Contenteditable input** -- the prompt textbox is contenteditable, not a standard input. `type` via OpenClaw relay works. If it doesn't, try `click` first to focus.

## Guidelines

- **Set aspect ratio FIRST** -- before typing the prompt. Most common mistake.
- **Intelligently select settings** -- based on prompt, choose appropriate ratio. Portrait = 9:16, cinematic = 16:9, square = 1:1.
- **Batch workflow** -- when generating many images, write a helper script rather than running individual commands.
- **Wait times** -- image generation 30-60s, video 60-180s.
- **Model** -- Nano Banana 2 for rapid iteration, Nano Banana Pro for higher quality.
- **Always use `--browser-profile claude`** -- never omit it. Other agents use their own profiles.
