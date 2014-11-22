/**
 * Embed Functions that skip the show/hide link for Item Pages
 * 
 */

function embedCfShowHideCss(i, width, height, flashvars) {
    var objectEmbed = embedTextCfInlineCss(width, height, 'autoplay=true&' + flashvars);
    document.write(objectEmbed);
}

function embedCfShowHideCssOver(i, width, height, flashvars, overdark, overbackground) {
    var objectEmbed = embedTextCfInlineCss(width, height, 'autoplay=true&' + flashvars, overdark, overbackground);
    document.write(objectEmbed);
}

function embedCfBasic(i, width, height, flashvars, overdark, overbackground) {
    embedCfShowHideCssOver(i, width, height, flashvars, overdark, overbackground);
}

function embedCfAdvanced(i, width, height, flashvars, overdark, overbackground) {
    embedCfShowHideCssOver(i, width, height, flashvars, overdark, overbackground);
}

/**
function embedCfShowHide(i, width, height, flashvars) {
    var objectEmbed = embedTextCfInline(width, height, 'autoplay=true&' + flashvars);
    document.write(objectEmbed);
}
**/

