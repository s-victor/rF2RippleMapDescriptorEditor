; This script requires AutoHotKey v2 to run
; -----------------------------------------
; Ripple movement direction code reference
; "↖"  -1.0,-1.0
; "↑"  +0.0,-1.0
; "↗"  +1.0,-1.0
; "←"  -1.0,+0.0
; "●"  +0.0,+0.0
; "→"  +1.0,+0.0
; "↙"  -1.0,+1.0
; "↓"  +0.0,+1.0
; "↘"  +1.0,+1.0

#SingleInstance Off
#NoTrayIcon
KeyHistory 0

; Metadata
TITLE := "rF2 Ripple Map Descriptor Editor"
DESCRIPTION := "Ripple map (raindrop movement direction) descriptor editor for rF2."
AUTHOR := "S.Victor"
VERSION := "0.1.0"

; GUI
ToolGui := Gui(, TITLE " v" VERSION)
ToolGui.OnEvent("Close", DialogConfirmClose)
StatBar := ToolGui.Add("StatusBar", , "")

; Constant
MAX_RIPPLE_SET := 16  ; increase this value for more control sets
CRLF := "`r`n"
WIN_MARGIN_X := ToolGui.MarginX
WIN_MARGIN_Y := ToolGui.MarginY
COLOR_BLOCK := "██████"
COLOR_PRESET := [
    "255,0,0", "0,255,0", "0,0,255", "255,255,0", "0,255,255", "255,0,255",
    "0,0,0", "255,255,255", "128,0,0", "0,128,0", "0,0,128", "128,128,0",
    "0,128,128", "128,0,128", "255,128,0", "128,255,0", "128,128,128"
]
DIR_X := ["-1.0", "+0.0", "+1.0", "-1.0", "+0.0", "+1.0", "-1.0", "+0.0", "+1.0"]
DIR_Y := ["-1.0", "-1.0", "-1.0", "+0.0", "+0.0", "+0.0", "+1.0", "+1.0", "+1.0"]
DIR_SIGN := [
    "↖ Left Up", "↑ Up", "↗ Right Up", "← Left", "● Still",
    "→ Right", "↙ Left Down", "↓ Down", "↘ Right Down"
]
DIR_SIGN_MATCH := Array()
Loop DIR_X.Length
{
    DIR_SIGN_MATCH.Push(DIR_X[A_Index] DIR_Y[A_Index])
}

; Button
ButtonOpen := ToolGui.Add("Button", "x" WIN_MARGIN_X - 1 " y" WIN_MARGIN_Y, "Open")
ButtonOpen.OnEvent("Click", DialogOpenFile)
ButtonExport := ToolGui.Add("Button", "x" 55 " y" WIN_MARGIN_Y, "Export as JSON")
ButtonExport.OnEvent("Click", DialogSaveFile)
ButtonCopy := ToolGui.Add("Button", "x" 160 " y" WIN_MARGIN_Y, "Copy to Clipboard")
ButtonCopy.OnEvent("Click", DialogCopyToClipboard)
ButtonAbout := ToolGui.Add("Button", "x650 y" WIN_MARGIN_Y, "About")
ButtonAbout.OnEvent("Click", DialogAbout)

; Control sets
RippleCtrlList := Array()
AddControlSets(RippleCtrlList, MAX_RIPPLE_SET)

; Output
OutputData := ToolGui.Add("Edit", "x0 y0 w0 h0 Hidden")

; Start GUI
ToolGui.Show()


; Controls
class RainDropControl
{
    __New(pos_x, pos_y, height, index, enabled, r_value := 128, g_value := 128, b_value := 128)
    {
        inner_gap := 6
        inner_x := pos_x + inner_gap + 2
        inner_y := pos_y + 6 + inner_gap

        ; Set enabled
        toggle_w := 55
        this.IsEnabled := ToolGui.Add("Checkbox", "x" inner_x " y" inner_y " w" toggle_w " h20", "Set " index)
        this.IsEnabled.Value := enabled

        ; Color display
        color_w := 55
        inner_x += inner_gap + toggle_w
        this.ColorText := ToolGui.Add("Text", "x" inner_x " y" inner_y " w" color_w " h20", COLOR_BLOCK)

        ; Color input
        color_in_w := 45
        inner_x += inner_gap + color_w
        this.ColorRedEdit := ToolGui.Add("Edit", "x" inner_x " y" inner_y " w" color_in_w " Number Limit3")
        this.ColorRedSpin := ToolGui.Add("UpDown", "Range0-255", r_value)

        inner_x += inner_gap + color_in_w
        this.ColorGreenEdit := ToolGui.Add("Edit", "x" inner_x " y" inner_y " w" color_in_w " Number Limit3")
        this.ColorGreenSpin := ToolGui.Add("UpDown", "Range0-255", g_value)

        inner_x += inner_gap + color_in_w
        this.ColorBlueEdit := ToolGui.Add("Edit", "x" inner_x " y" inner_y " w" color_in_w " Number Limit3")
        this.ColorBlueSpin := ToolGui.Add("UpDown", "Range0-255", b_value)

        ; Combo box
        button_w := 110
        inner_x += inner_gap + color_in_w
        this.ComboStill := ToolGui.Add("DropDownList", "x" inner_x " y" inner_y " w" button_w " Choose5", DIR_SIGN)
        inner_x += inner_gap + button_w
        this.ComboMove := ToolGui.Add("DropDownList", "x" inner_x " y" inner_y " w" button_w " Choose5", DIR_SIGN)

        ; Description
        desc_w := 160
        inner_x += inner_gap + button_w
        this.DescEdit := ToolGui.Add("Edit", "x" inner_x " y" inner_y " w" desc_w)

        ; Draw frame
        ToolGui.Add("GroupBox", "x" pos_x " y" pos_y " w" inner_x + desc_w - 2 " h" height, "")

        ; Update state
        ApplyColor(this)
        ToggleControlState(this)
    }
}


; GUI function
AddControlSets(ctrl_array, num_ctrl)
{
    ctrl_offset_y := WIN_MARGIN_Y + 22
    ctrl_height := 40
    enabled := true
    Loop num_ctrl
    {
        if (A_Index > 6)
        {
            enabled := false
        }
        if (A_Index > COLOR_PRESET.Length)
        {
            color_rgb := StrSplit(COLOR_PRESET[-1], ",")
        }
        else
        {
            color_rgb := StrSplit(COLOR_PRESET[A_Index], ",")
        }
        ctrl := RainDropControl(WIN_MARGIN_X, ctrl_offset_y, ctrl_height, A_Index, enabled, color_rgb[1], color_rgb[2], color_rgb[3])
        SetControlEvent(ctrl)
        ctrl_array.Push(ctrl)
        ctrl_offset_y += ctrl_height
    }
}


SetControlEvent(ctrl)
{
    ctrl.IsEnabled.OnEvent("Click", (*) => ToggleControlState(ctrl))
    ctrl.ColorRedEdit.OnEvent("Change", (*) => ApplyColor(ctrl))
    ctrl.ColorGreenEdit.OnEvent("Change", (*) => ApplyColor(ctrl))
    ctrl.ColorBlueEdit.OnEvent("Change", (*) => ApplyColor(ctrl))
    ctrl.ColorRedSpin.OnEvent("Change", (*) => ApplyColor(ctrl))
    ctrl.ColorGreenSpin.OnEvent("Change", (*) => ApplyColor(ctrl))
    ctrl.ColorBlueSpin.OnEvent("Change", (*) => ApplyColor(ctrl))
}


ApplyColor(ctrl)
{
    hex_r := DecimalToHexColor(ctrl.ColorRedEdit)
    hex_g := DecimalToHexColor(ctrl.ColorGreenEdit)
    hex_b := DecimalToHexColor(ctrl.ColorBlueEdit)
    ctrl.ColorText.SetFont("c" hex_r hex_g hex_b " s13", "Consolas")
}


DecimalToHexColor(ctrl)
{
    if IsNumber(ctrl.Value)
    {
        ctrl.Value := Min(Max(ctrl.Value, 0), 255)
    }
    else
    {
        ctrl.Value := 0
    }
    ControlSend "{End}", ctrl  ; correct input pointer position
    return Format("{:02X}", ctrl.Value)
}


ValidateJsonString(ctrl)
{
    ctrl.Value := RegExReplace(ctrl.Value, "`"*`'*", "")
    return ctrl.Value
}


ToggleControlState(ctrl)
{
    state := ctrl.IsEnabled.Value
    ctrl.ColorText.Enabled := state
    ctrl.ColorRedEdit.Enabled := state
    ctrl.ColorRedSpin.Enabled := state
    ctrl.ColorGreenEdit.Enabled := state
    ctrl.ColorGreenSpin.Enabled := state
    ctrl.ColorBlueEdit.Enabled := state
    ctrl.ColorBlueSpin.Enabled := state
    ctrl.ComboStill.Enabled := state
    ctrl.ComboMove.Enabled := state
    ctrl.DescEdit.Enabled := state
}


LoadControlSets(loaded_data)
{
    loaded_data.Delete("Desc")
    total_sets := Min(loaded_data.Count, RippleCtrlList.Length)
    ; Disable all control sets
    For ctrl in RippleCtrlList
    {
        ctrl.IsEnabled.Value := false
        ctrl.ComboStill.Value := 5
        ctrl.ComboMove.Value := 5
        ctrl.DescEdit.Value := ""
        ToggleControlState(ctrl)
    }
    ; Apply loaded data to control sets
    For set_key in loaded_data
    {
        ctrl := RippleCtrlList[A_Index]
        ctrl.IsEnabled.Value := true
        ctrl.ColorRedEdit.Value := loaded_data[set_key]["Color"]["R"]
        ctrl.ColorGreenEdit.Value := loaded_data[set_key]["Color"]["G"]
        ctrl.ColorBlueEdit.Value := loaded_data[set_key]["Color"]["B"]
        ctrl.DescEdit.Value := loaded_data[set_key]["Description"]
        ctrl.ComboStill.Value := MatchComboIndex(
            loaded_data[set_key]["StillDirection"]["X"]
            loaded_data[set_key]["StillDirection"]["Y"],
            DIR_SIGN_MATCH
        )
        ctrl.ComboMove.Value := MatchComboIndex(
            loaded_data[set_key]["MovementDirection"]["X"]
            loaded_data[set_key]["MovementDirection"]["Y"],
            DIR_SIGN_MATCH
        )
        ApplyColor(ctrl)
        ToggleControlState(ctrl)
        if (A_Index >= total_sets)
        {
            break
        }
    }
    StatBar.SetText(" File loaded, number of sets:" total_sets)
}


MatchComboIndex(text, data_array)
{
    For data in data_array
    {
        if (data = text)
        {
            return A_Index
        }
    }
    return 5
}


RippleDescriptorJsonParser(filename)
{
    temp_dict := Map()
    level := 0
    sub_key1 := ""
    sub_key2 := ""
    sub_key3 := ""
    check_next_value := false
    check_next_dict := false
    valid_counter := 0
    ; Read raindrop_desc.json file
    Loop read, filename
    {
        ; Delimiter by quotation mark, line break
        Loop Parse, A_LoopReadLine, "`r`n`""
        {
            ; Remove leading & trailing space/tab/comma/colon
            value_strip := Trim(A_LoopField, A_Tab A_Space ":,")
            ; Basic validation, abort after 4 tries
            if (valid_counter < 5)
            {
                valid_counter += 1
                if (value_strip = "Desc")
                {
                    valid_counter := 5
                }
                if (valid_counter = 4)
                {
                    return false
                }
            }
            if (value_strip = "")
            {
                continue
            }
            ;--------------
            if (value_strip = "{")
            {
                check_next_value := false
                check_next_dict := true
                continue
            }
            if (value_strip = "}")
            {
                level -= 1
                continue
            }
            ;--------------
            if (check_next_value)
            {
                check_next_value := false
                if (level = 1)
                {
                    temp_dict[sub_key1] := value_strip
                }
                else if (level = 2)
                {
                    temp_dict[sub_key1][sub_key2] := value_strip
                }
                else if (level = 3)
                {
                    temp_dict[sub_key1][sub_key2][sub_key3] := value_strip
                }
                continue
            }
            if (check_next_dict)
            {
                check_next_dict := false
                if (level = 1)
                {
                    temp_dict[sub_key1] := Map()
                }
                else if (level = 2)
                {
                    temp_dict[sub_key1][sub_key2] := Map()
                }
                else if (level = 3)
                {
                    temp_dict[sub_key1][sub_key2][sub_key3] := Map()
                }
                level += 1
            }
            ;--------------
            if (level = 1)
            {
                sub_key1 := value_strip
                check_next_value := true
                continue
            }
            if (level = 2)
            {
                sub_key2 := value_strip
                check_next_value := true
                continue
            }
            if (level = 3)
            {
                sub_key3 := value_strip
                check_next_value := true
                continue
            }
        }
    }
    return temp_dict
}


; Output function
OutputJson(*)
{
    ; Clear old data
    OutputData.Value := ""
    ; Check number of enabled sets
    num_enabled := 0
    For ctrl in RippleCtrlList
    {
        if (ctrl.IsEnabled.Value != 0)
        {
            num_enabled += 1
        }
    }
    ; Abort if none set enabled
    if (num_enabled < 1)
    {
        StatBar.SetText(" Generating aborted")
        DialogNoSet()
        return false
    }
    ; Generate code
    GenerateHeader(num_enabled)
    set_index := 0
    end_comma := ","  ; skip final comma
    For ctrl in RippleCtrlList
    {
        if (ctrl.IsEnabled.Value != 0)
        {
            set_index += 1
            if (set_index = num_enabled)
            {
                end_comma := ""
            }
            GenerateDescriptor(ctrl, set_index, end_comma)
        }
    }
    GenerateFooter()
    StatBar.SetText(" Generating completed, number of sets:" num_enabled)
    return true
}


GenerateHeader(num_enabled)
{
    text := (
        "{" CRLF
        A_Tab "`"Desc`":" CRLF
        A_Tab "{" CRLF
        A_Tab A_Tab "`"NumberOfSets`":" num_enabled "," CRLF
        A_Tab A_Tab "`"MinLengthSqrt`":" 0.25 CRLF
        A_Tab "}," CRLF
    )
    EditPaste(text, OutputData)
}


GenerateFooter(*)
{
    text := "}" CRLF
    EditPaste(text, OutputData)
}


GenerateDescriptor(ctrl, set_index, end_comma)
{
    index_still := ctrl.ComboStill.Value
    index_move := ctrl.ComboMove.Value
    comment := ValidateJsonString(ctrl.DescEdit)
    text := (
        A_Tab "`"Set_" set_index "`":" CRLF
        A_Tab "{" CRLF
        A_Tab A_Tab "`"Color`":" CRLF
        A_Tab A_Tab "{" CRLF
        A_Tab A_Tab A_Tab "`"R`":" ctrl.ColorRedSpin.Value "," CRLF
        A_Tab A_Tab A_Tab "`"G`":" ctrl.ColorGreenSpin.Value "," CRLF
        A_Tab A_Tab A_Tab "`"B`":" ctrl.ColorBlueSpin.Value "," CRLF
        A_Tab A_Tab "}," CRLF
        A_Tab A_Tab "`"StillDirection`":" CRLF
        A_Tab A_Tab "{" CRLF
        A_Tab A_Tab A_Tab "`"X`":" DIR_X[index_still] "," CRLF
        A_Tab A_Tab A_Tab "`"Y`":" DIR_Y[index_still] "," CRLF
        A_Tab A_Tab "}," CRLF
        A_Tab A_Tab "`"MovementDirection`":" CRLF
        A_Tab A_Tab "{" CRLF
        A_Tab A_Tab A_Tab "`"X`":" DIR_X[index_move] "," CRLF
        A_Tab A_Tab A_Tab "`"Y`":" DIR_Y[index_move] "," CRLF
        A_Tab A_Tab "}," CRLF
        A_Tab A_Tab "`"Description`"`:`"" comment "`"" CRLF
        A_Tab "}" end_comma CRLF
    )
    EditPaste(text, OutputData)
}


; Dialog function
DialogCopyToClipboard(*)
{
    finished := OutputJson()
    if (finished)
    {
        A_Clipboard := OutputData.Value
        MsgBox(" Copied Generated Data to Clipboard", "Copy to Clipboard")
    }
}


DialogSaveFile(*)
{
    finished := OutputJson()
    if (!finished)
    {
        return
    }
    ToolGui.Opt("+OwnDialogs")
    filename := FileSelect("S16", "raindrop_desc.json", "Save As", "JSON file (*.json)")
    if (!filename)
    {
        return
    }
    try
    {
        if FileExist(filename)
        {
            FileDelete(filename)
        }
        FileAppend(OutputData.Value, filename)
        StatBar.SetText(" Saved at " filename)
    }
}


DialogOpenFile(*)
{
    ToolGui.Opt("+OwnDialogs")
    filename := FileSelect(3, "raindrop_desc.json", "Open file", "JSON file (*.json)")
    if (!filename)
    {
        return
    }
    try
    {
        loaded_data := RippleDescriptorJsonParser(filename)
        if (loaded_data)
        {
            LoadControlSets(loaded_data)
        }
        else
        {
            throw Error("Failed to load file.")
        }
    }
    catch Error
    {
        DialogFileLoadError()
    }
}


DialogAbout(*)
{
    info := TITLE " v" VERSION CRLF "by " AUTHOR CRLF CRLF DESCRIPTION CRLF CRLF
    MsgBox(info, "About")
}


DialogNoSet(*)
{
    return MsgBox(
        "No ripple control set enabled.`n`n"
        "Enable at least one ripple control set to export.",
        "Warning",
    )
}


DialogFileLoadError(*)
{
    return MsgBox(
        "Failed to load selected file.`n`n"
        "Please select a valid raindrop_desc.json file.",
        "Error",
    )
}


DialogConfirmClose(*)
{
    result := MsgBox(
        "Are you sure you want to close?`n`n"
        "Unsaved changes will be lost.",
        "Confirm",
        "YesNo"
    )
    return result = "No"
}