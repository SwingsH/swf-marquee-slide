/**
 * ImageViewer，Version 4
 * 在螢幕上顯示載入影像的矩形區域。
 * 範例檔網址：http://moock.org/eas2/examples/
 *
 * @author: Colin Moock
 * @author: Swings Huang (modify)
 * @version: 4.0.0
 */
 

class ImageViewer {
  // 將包含所有ImageViewer資產的影片片段
  private var container_mc:MovieClip;
  // 將附加container_mc的影片片段
  private var target_mc:MovieClip;

  // 視覺資產的深度值
  private var containerDepth:Number;  
  private static var imageDepth:Number = 0;
  private static var maskDepth:Number = 1;
  private static var borderDepth:Number = 2;
  private static var statusDepth:Number = 3;

  // 圍繞影像周圍的邊框的粗細
  private var borderThickness:Number;
  // 影像邊框的顏色
  private var borderColor:Number;
  // 影像邊框的寬度
  private var borderWidth:Number;
  // 影像邊框的高度
  private var borderHeight:Number;

  // 用來載入影像的MovieClipLoader實體
  private var imageLoader:MovieClipLoader;
  
  // 指定觀看器能否縮放大小
  // 以便符合影像尺寸的旗標。 
  private var showFullImage:Boolean = false;

  /**
   * ImageViewer建構子
   *
   * @param   target           	附加ImageViewer的影片片段
   * @param   depth            	在target中附加viewer的深度值
   * @param   x 			 	觀看器的水平座標值
   * @param   y 			 	觀看器的垂直座標值
   * @param   w 			 	觀看器的寬度值（單位為像素）
   * @param   h 			 	觀看器的高度值（單位為像素）
   * @param   borderThickness  	影像邊框的粗細
   * @param   borderColor      	影像邊框的顏色
   *                   
   */
  public function ImageViewer (target:MovieClip, 
                               depth:Number, 
                               x:Number, 
                               y:Number, 
                               w:Number, 
                               h:Number,
                               borderThickness:Number,
                               borderColor:Number) {
    // 指派屬性值
    target_mc = target;
    containerDepth = depth;
    this.borderThickness = borderThickness;
    this.borderColor = borderColor;
	this.borderWidth = w ;
	this.borderHeight = h ;
    imageLoader = new MovieClipLoader(  );

    // 註冊這個實體來接收發自imageLoader
    // 實體的事件
    imageLoader.addListener(this);

    // 設定這個ImageViewer的視覺資產
    buildViewer(x, y, w, h);
  }

  /**
   * 替這個ImageViewer建立螢幕上的資產
   * 此影片片段的階層如下：
   *  [d]: container_mc
   *         2: border_mc
   *         1: mask_mc（遮罩image_mc）
   *         0: image_mc
   * 其中的[d]是用戶提供給此建構子的深度值。
   *
   * @param   x   此檢視區域（viewer）的水平座標
   * @param   y   此檢視區域的垂直座標
   * @param   w   此檢視區域的寬度（單位為像素）
   * @param   h   此檢視區域的高度（單位為像素）
   */
  private function buildViewer (x:Number, 
                                y:Number, 
                                w:Number, 
                                h:Number):Void {
      // 建立用來存放影像、遮罩與邊框的影片片段
      createMainContainer(x, y);
      createImageClip(  );
      createImageClipMask(w, h);
      createBorder(w, h);
  }

  /**
   * 建立一個用來包含ImageViewer視覺資產的 
   * container_mc影片片段。
   *
   * @param   x   container_mc影片片段的水平座標 
   * @param   y   container_mc影片片段的垂直座標
   */
  private function createMainContainer (x:Number, y:Number):Void {
    container_mc = target_mc.createEmptyMovieClip(
                                           "container_mc" + containerDepth, 
                                           containerDepth);
    container_mc._x = x;
    container_mc._y = y;
  }

  /**
   * 建立實際載入影像檔的影片片段
   */
  private function createImageClip (  ):Void {
    container_mc.createEmptyMovieClip("image_mc", imageDepth);
  }
  /**
   * 建立疊在影像上的遮罩。請注意這個方法並未
   * 把此遮罩套用到影像片段上，因為當新的內容
   * 載入影像片段後，原先放置的遮罩片段將會消
   * 失。因此，遮罩片段由onLoadInit()套用。
   *
   * @param   w   遮罩的寬度（單位為像素）
   * @param   h   遮罩的高度（單位為像素）
   */
  private function createImageClipMask (w:Number,
                                        h:Number):Void {
    // 只有在指定有效的寬度和高度值的情況下，才建立遮罩。
    if (!(w > 0 && h > 0)) {
      return;
    }

    // 在容器片段中，建立當作遮罩的影片片段。
    container_mc.createEmptyMovieClip("mask_mc", maskDepth);

    // 在遮罩中繪製一個矩形
    container_mc.mask_mc.moveTo(0, 0);
    // 為了方便除錯所以用藍色
    container_mc.mask_mc.beginFill(0x0000FF);
    container_mc.mask_mc.lineTo(w, 0);
    container_mc.mask_mc.lineTo(w, h);
    container_mc.mask_mc.lineTo(0, h);
    container_mc.mask_mc.lineTo(0, 0);
    container_mc.mask_mc.endFill(  );
  
    // 隱藏遮罩（即使看不見，它仍具有遮色片的功用）。
     container_mc.mask_mc._visible = false; 
  }

  /**
   * 建立影像邊框
   *
   * @param   w     邊框的寬度（單位為像素）
   * @param   h		邊框的高度（單位為像素）
   */
  private function createBorder (w:Number,
                                 h:Number):Void {
    // 只有在指定有效的寬度和高度值時，才建立邊框。
    if (!(w > 0 && h > 0)) {
      return;
    }

    // 在容器片段中，建立包含影像邊框的片段。
    container_mc.createEmptyMovieClip("border_mc", borderDepth);
  
    // 在邊框片段裡面繪製一個指定大小和顏色的矩形邊框。
    container_mc.border_mc.lineStyle(borderThickness, borderColor);
    container_mc.border_mc.moveTo(0, 0);
    container_mc.border_mc.lineTo(w, 0);
    container_mc.border_mc.lineTo(w, h);
    container_mc.border_mc.lineTo(0, h);
    container_mc.border_mc.lineTo(0, 0);
  }

  /**
   * 將JPEG檔載入影像檢視區
   *
   * @param   URL   本地或遠端的載入影像檔的位元元址
   */
  public function loadImage (URL:String):Void {
    imageLoader.loadClip(URL, container_mc.image_mc);

    // 建立顯示載入進度的文字欄位
    container_mc.createTextField("loadStatus_txt", statusDepth, 0, 0, 0, 0);
    container_mc.loadStatus_txt.background = true;
    container_mc.loadStatus_txt.border = true;
    container_mc.loadStatus_txt.setNewTextFormat(new TextFormat(
                                                 "Arial, Helvetica, _sans",
                                                 10, borderColor, false,
                                                 false, false, null, null,
                                                 "right"));
    container_mc.loadStatus_txt.autoSize = "left";

    // 設定載入狀態欄位的位置
    container_mc.loadStatus_txt._y = 3;
    container_mc.loadStatus_txt._x = 3;

    // 指出已經開始載入影像
    container_mc.loadStatus_txt.text = "載入中";
  }

  /**
   * MovieClipLoader處理程式。當資料抵達時，由imageLoader觸發。
   * 
   * @param   target        參考到開始回報載入進度的影片片段
   * @param   bytesLoaded   截至目前，target所載入的位元組數。 
   * @param   bytesTotal    target的總位元組大小
   */
  public function onLoadProgress (target:MovieClip, 
                                  bytesLoaded:Number, 
                                  bytesTotal:Number):Void {
    container_mc.loadStatus_txt.text = "載入中：" 
        + Math.floor(bytesLoaded / 1024)
        + "/" + Math.floor(bytesTotal / 1024) + " KB";
  }

  /**
   * MovieClipLoader處理程式。當載入完畢時，由imageLoader觸發。
   * 
   * @param   target   參考到載入完成的影片片段
   */
  public function onLoadInit (target:MovieClip):Void {
    // 移除「載入中」的訊息
    container_mc.loadStatus_txt.removeTextField(  );

    // 在載入的影像上套用遮罩
	container_mc.image_mc.setMask(container_mc.mask_mc);
	
	// 增加自動調整尺寸的功能。
	if (showFullImage) {
      scaleViewerToImage();
    }
	// 如果為有效的寬度和高度值 , 依據邊寬大小調整影像
	else if( !(borderWidth < 0 || borderHeight < 0) ){
		scaleImageToViewer(borderWidth,borderHeight);
	}
  }

  /**
   * MovieClipLoader處理程式。當載入失敗時，由imageLoader觸發。
   *
   * 
   * @param   target      參考到載入失敗的影片片段
   * @param   errorCode   指出載入失敗原因的字串
   */
  public function onLoadError (target:MovieClip, errorCode:String):Void {
    if (errorCode == "URLNotFound") {
      container_mc.loadStatus_txt.text = " 錯誤：找不到檔案。";
    } else if (errorCode == "LoadNeverCompleted") {
      container_mc.loadStatus_txt.text = " 錯誤：載入失敗。";
    } else {
      // 捕捉其他所有可能的錯誤代碼。
      container_mc.loadStatus_txt.text = " 載入錯誤：" + errorCode;
    }
  }

  /**
   * 必須在刪除ImageViewer實體之前被呼叫。
   * 讓實體有機會刪除它所建立的任何資源。
   */
  public function destroy (  ):Void {
    // 取消事件通知
    imageLoader.removeListener(this);
    // 移除舞台上的影片片段
    container_mc.removeMovieClip(  );
  }
  
/**
 * 以下原為ImageViewerDeluxe替ImageViewer新增了重新設定座標和大小的功能 
 * 被整合到ImageViewer
 * 範例檔網址：http://www.moock.org/eas2/examples/.
 *
 * @author: Colin Moock
 * @version: 2.0.0
 */
   
  /**
  * 設定觀看器的座標
  *
  * @param   x  	觀看器的新水平座標。
  * @param   y		觀看器的新垂直座標。
  */
  public function setPosition (x:Number, y:Number):Void {
    container_mc._x = x;
    container_mc._y = y;
  }

  /**
  * 設定觀看器的尺寸（亦即，調整邊框和遮罩的大小）。
  *
  * @param   w		觀看器的新寬度，單位為像素。
  * @param   h		觀看器的新高度，單位為像素。
  */
  public function setSize (w:Number, h:Number):Void {
    createImageClipMask(w, h);
    createBorder(w, h);
    container_mc.image_mc.setMask(container_mc.mask_mc);
  }

  /**
  * 傳回包含載入影像的影片片段的寬度。
  */
  public function getImageWidth ():Number {
    return container_mc.image_mc._width;
  }

  /** 
  * 傳回包含載入影像的影片片段的高度。
  */
  public function getImageHeight ():Number {
    return container_mc.image_mc._height;
  }

  /**
  * 設定指出是否呈現整張圖像或者裁切圖像
  * 使它符合觀看器大小的旗標。
  *
  * @param   show   指出是否要縮放觀看器讓它
  *                 吻合圖像的大小
  */
  public function setShowFullImage(show:Boolean):Void {
    showFullImage = show;
  }

  /**
  * 傳回是否呈現整張圖像或者裁切圖像
  * 使它符合觀看器大小的旗標。
  */ 
  public function getShowFullImage():Boolean {
    return showFullImage;
  }

  /**
  * 調整觀看器的大小，
  * 來呈現整張圖像。 
  */ 
  public function scaleViewerToImage ():Void {
    setSize(getImageWidth(), getImageHeight());
  }
  
  /**
  * 調整圖像的大小，
  * 來呈現整張圖像。 
  */ 
  public function scaleImageToViewer (w :Number , h : Number):Void {
     container_mc.image_mc._width = w ;
	 container_mc.image_mc._height = h ;
  }

}