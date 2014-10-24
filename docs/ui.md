# UI API
[-> Watch](https://github.com/MultHub/LMNet-OS/blob/master/src/apis/ui.lua)
### Autoloaded with LMNet-OS

| Function | return | Description |
|:-----------------------------------------------------------------------------------------------:|-----------------|---------------------------------------------|
| ui.cprint(text) | nil | Writes the text in the middle of the screen |
| ui.menu(table Items, String Title, [Number StartValue], [Boolean allowNil], [Table moreTitles]) | Items[selected] | An Keyboard and Mouse-friendly menu |
| ui.yesno(text, title, start) | Boolean |An Yes/No Menu  |
| ui.colorPicker(title, moreText, custumColors) | Color |
| ui.button(pLabel, xPos, yPos, pColor) | button Element | A button Object |
| ui.progressBar(xPos, yPos, length, color, text) | progressBar Element | A progress bar as object |
| ui.splitStr(string, maxWidth) | table splitted String | Split a String to be not in a line |
| ui.textField(id, xPos, yPos, BackgroundColor, TextColor | textField Object | A textField |
| ui.contextMenu(tableItems, xPos, yPos, id) | contextMenu Object | Like a menu on right click |
| ui.textToTable(allowNil, ... ) | table TextField Values | Creates of all textFields on ... a table with the values |
| ui.createSwitch(tableElements, yPos, colorSelect, colorNormal, id) | Switch object | A group of buttons |

---
# Objects
## button

## switch
####  attributes
| Key | type | value |
|:-----------------------------------------------------------------------------------------------:|-----------------|---------------------------------------------|
| type | String | "switch" |
| id | String/Number | The ID that you given |
| buttons | table | extents all buttons |
| color | number (color) | Color of a button |
| colorSelect | number (color) | Color of the selectet button |
| onClick | nil / function | Would be called onClick of a button (Args value, selectetButton) |
| y | number | Y Pos of the switch |
| select | button Object | the selectet button Object |
#### Methods (called whith switch:method() )
| key | return | desc |
|:-----------------------------------------------------------------------------------------------:|-----------------|---------------------------------------------|
| :draw() | nil | draws the buttons |
| :value() | String | return the Label of the button |
| :isClicked(xPos, yPos) | boolean, button | checks if a button is Clicked |
## contextMenu
#### attributes
| key | type | value |
|:-----------------------------------------------------------------------------------------------:|-----------------|---------------------------------------------|
| items | table | the Items inside that menu |
| x | number | X Pos of Menu |
| y | number | Y Pos of Menu |
| color | number (color) | Color of the menu; colors.white |
| textColor | number (color) | Color of the text; colors.black |
| clicked | boolean | If called :isClicked() this can be true |
| len | number | lenght of the menu (y) |
| wide | number | wide of the menu (x) |
| onClickActions | table | if you want that happen anything if is click on an element use menu["onClickActions"][<Name Of Element>] = function() ... |
| type | String | "contextMenu" |
| id | String / number | ID of the menu |
#### methods
| key | return | desc |
|:-----------------------------------------------------------------------------------------------:|-----------------|---------------------------------------------|
| :draw() | nil | draw the menu |
| :isClicked(X, Y, ...) | boolean, object | return true if pX and pY in the Menu and the obj ( ... are in your function) |
## textField
#### Attrbutes
| key | type | value |
|:-----------------------------------------------------------------------------------------------:|-----------------|---------------------------------------------|
| x | number | x Pos of the textField |
| y | number | y Pos of the textField |
| len | number | len of the textField |
| textColor | number (color) | Self explain |
| backgroundColor | number (color) | Self explain |
| value | String | Text Value of the textField |
| id | String/Number | ID |
| text | String | The Placeholder |
| type | String | "textField" |
#### Methods
| key | return | desc |
|:-----------------------------------------------------------------------------------------------:|-----------------|---------------------------------------------|
| :draw() | nil | same as in other Objects |
| :isClicked(X, Y) | boolean | Same as others, activate read() |
| :warn() | nil | PLANNED |
