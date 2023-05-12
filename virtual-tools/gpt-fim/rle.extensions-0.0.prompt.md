
⚟NLP 0.3
@gpt-fim extend rle- generate a rle encoded image using a provided table_render(rle_data, table_id, cols, rows, xwidth, ywidth) function. That is already available in this session and callable. 
inside of the standard llm-fim tag include a script that populates fully (no skipped values_ rle , chooses a unique id and passes the user specified colsXrows fields. if not specified default to 32x32.  if --res=XxY is not provided default to 320x320

gpt-fim rle relies on @mh to correctly calculate it's run lengths. Like all gpt-fim method it outputs using the <llm-fim/> tag wrapper. It does not output meta notes. It double checks it's rle after the first output and reassigns to rle var if it sees a mistake. That is it uses @mh to insure the lengths are correct, if there was a mistake it reassigns. rle with the fix. It uses as small as possible var names to avoid filling context.

# exmaple output  <-- use this unless @rle-xss=true

#example  output
<llm-fim>
<title>green table with a blue dot in the center. </title>
<content type="rle">
<div class="rle" id="tab_one"></div>
{if @rle-xss!=true}
<pre class="rle-data" data-target="tab_one" data-cols="16" data-rows="16" data-x="640" data-y="640">
[
["#0F0", 16],
["#0F0", 16],
["#0F0", 16],
["#0F0", 16],
["#0F0", 16],
["#0F0", 16],
["#0F0", 7, "#00F", 2, "0F0", 7],
["#0F0", 16],
["#0F0", 16],
["#0F0", 16],
["#0F0", 16],
["#0F0", 16],
["#0F0", 16],
["#0F0", 16],
["#0F0", 16],
["#0F0", 16]
]</pre>
{/if}
{if @rle-xss==true}
<script>
(function() {
alert('loaded')
// green row
let gr = ["#0F0", 16] ;
let rle = [gr,gr,gr,gr,gr,gr,gr,["#0F0", 7, "#00F", 2, "0F0", 7],gr,gr,gr,gr,gr,gr,gr,gr];
let id = "tab_one";
window.table_render(rle, id, 32,32, 320, 320);
alert('loaded')
}
})()
</script>
{/if}
</content>
</llm-fim>
⚞
