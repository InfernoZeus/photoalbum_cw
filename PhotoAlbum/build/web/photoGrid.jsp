    <div id="mainArea">
      <div id="zoom0"  ondblclick="popupImage(_currentImage % 9);" class="zoom"><img id="zoomImage" src="" width="200" height="200"/></div>
      <div id="grid0" class="grid">
        <table cellpadding="0" cellspacing="0">
          <tr>
            <td><span class="caption" id="cap0">Caption 1</span><div id="thumbContainer0" class="thumbContainer" onclick="singleClick(0); return false" ondblclick="doubleClick(0); return false"><a href="#"><img id="thumbnail0" src=""></a></div></td>
            <td><span class="caption" id="cap1">Caption 2</span><div id="thumbContainer1" class="thumbContainer" onclick="singleClick(1); return false" ondblclick="doubleClick(1); return false"><a href="#"><img id="thumbnail1" src=""></a></div></td>
            <td><span class="caption" id="cap2">Caption 3</span><div id="thumbContainer2" class="thumbContainer" onclick="singleClick(2); return false" ondblclick="doubleClick(2); return false"><a href="#"><img id="thumbnail2" src=""></a></div></td>
          </tr>
          <tr>
            <td><span class="caption" id="cap3">Caption 4</span><div id="thumbContainer3" class="thumbContainer" onclick="singleClick(3); return false" ondblclick="doubleClick(3); return false"><a href="#"><img id="thumbnail3" src=""></a></div></td>
            <td><span class="caption" id="cap4">Caption 5</span><div id="thumbContainer4" class="thumbContainer" onclick="singleClick(4); return false" ondblclick="doubleClick(4); return false"><a href="#"><img id="thumbnail4" src=""></a></div></td>
            <td><span class="caption" id="cap5">Caption 6</span><div id="thumbContainer5" class="thumbContainer" onclick="singleClick(5); return false" ondblclick="doubleClick(5); return false"><a href="#"><img id="thumbnail5" src=""></a></div></td>
          </tr>
          <tr>
            <td><span class="caption" id="cap6">Caption 7</span><div id="thumbContainer6" class="thumbContainer" onclick="singleClick(6); return false" ondblclick="doubleClick(6); return false"><a href="#"><img id="thumbnail6" src=""></a></div></td>
            <td><span class="caption" id="cap7">Caption 8</span><div id="thumbContainer7" class="thumbContainer" onclick="singleClick(7); return false" ondblclick="doubleClick(7); return false"><a href="#"><img id="thumbnail7" src=""></a></div></td>
            <td><span class="caption" id="cap8">Caption 9</span><div id="thumbContainer8" class="thumbContainer" onclick="singleClick(8); return false" ondblclick="doubleClick(8); return false"><a href="#"><img id="thumbnail8" src=""></a></div></td>
          </tr>
        </table>
      </div>      
    </div>
    <div id="navControls">
      <input type="image" src="images/first.gif" onclick="firstPage();" />
      <input type="image" src="images/prev.gif" onclick="prevPage();" />
      <input type="image" src="images/next.gif" onclick="nextPage();" />
      <input type="image" src="images/last.gif" onclick="lastPage();" />
    </div>    