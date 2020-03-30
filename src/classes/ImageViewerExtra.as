/**********************************
* ImageViewer ， 在螢幕上顯示載入影像的矩形區域。
* ImageViewerExtra ， 並附加影像的事件 ，滑鼠事件、圖片連結…等額外功能
*
* @id		: ImageViewExtra
* @author	: Swings Huang (E-mail:silverwings999@hotmail.com)
* @version	: 1.0.0
***********************************/

class ImageViewerExtra extends ImageViewer{
	
	// 專職 ImageViewerExtra 效果的影片片段
	private var effect_mc : MovieClip ;
	
	// 視覺資產的深度值
	// Depth of view assets
	private static var effectDepth:Number = 6;
	
	// 效果影片片段的設定值
	// Effect sets
	private var effectMethod : String ;
	// 使用 load 方法時, 外部讀入 swf 的 Path
	// Using load method, Path of swf 
	private var effectPath : String ;
	// 使用 attach 方法時, 影片片段在元件庫的 ID
	// Using attach method, ID of swf 
	private var effectID : String ;
	
	// 儲存事件處理函式的物件
	// Object to store event function
	
	private var eventObject : Object = new Object() ;
	
	/**
	* ImageViewerExtra建構子
	*
	* @param   target          	附加ImageViewer的影片片段
	* @param   depth           	在target中附加viewer的深度值
	* @param   x 			 	觀看器的水平座標值
	* @param   y 			 	觀看器的垂直座標值
	* @param   w 				觀看器的寬度值（單位為像素）
	* @param   h 				觀看器的高度值（單位為像素）
	* @param   borderThickness  影像邊框的粗細
	* @param   borderColor      影像邊框的顏色
	*/
	function ImageViewerExtra(target:MovieClip, 
								depth:Number, 
								x:Number, 
								y:Number, 
								w:Number, 
								h:Number,
								borderThickness:Number,
								borderColor:Number){
		super(target, depth, x, y, w, h, borderThickness, borderColor);
	}
	
	/**
	* MovieClipLoader處理程式。當載入完畢時，由imageLoader觸發。
	* 
	* @param   target   參考到載入完成的影片片段
	*/
	public function onLoadInit (target:MovieClip):Void {
		
		super.onLoadInit(target);
		
		// 建立特效影片片段實體
		createEffect();
		// 建立主影片片段 container_mc 事件處理函式
		assignEvents();
	}

	/**
	* 設定圖片附加的特效影片片段 ， 並可選擇性(Optional)設定
	* 特效影片片段的事件處理函式 ， 使特效影片片段依據不同事件
	* 做變化
	*
	* @param  method		特效影片片段的附加方式，可接受的參數為
	*						"attach" ， "load"
	* @param  path_or_id	附加的路徑，可接受任何字串
	* @param  [eventType]	mix vars ，選擇性(Optional)的參數，必須三個一組
	*						事件的種類，可接受的參數為
	*						"onRelease" ， "onRollOut" ， "onRollOver" 等
	* @param  [eventAction]	事件的種類，可接受的參數為
	*						"gotoAndPlay" ， "gotoAndStop"
	* @param  [eventLabel]	效果影片片段在該事件觸發後
	*						該前往的標籤
	*/
	public function setAddedEffect( method:String , path_or_id : String):Void {
		var id : Number = 2 ;
		switch(method){
			case "attach":
				effectMethod = method ;
				effectID = path_or_id ;
				effectPath = null ;
			break ;
			case "load":
				effectMethod = method ;
				effectPath = path_or_id ;
				effectID = null ;
			break ;
			default:
				effectMethod = null ;
		}
		
		for( ; arguments[id] ; id = id+3 ){
			setEffectEvent(arguments[id],arguments[id+1],arguments[id+2]);
		}
	}
	
	/**
	* 設定特效影片片段的事件處理函式 event function 
	* 方法為特效專用 ， 只能針對 effect_mc 做變化
	*
	* @param	eventType	事件的種類，可接受的參數為
	*						"onRelease" ， "onRollOut" ， "onRollOver" 等
	* @param	eventAction	事件的種類，可接受的參數為
	*						"gotoAndPlay" ， "gotoAndStop"
	* @param	eventLabel	效果影片片段在該事件觸發後
	*						該前往的標籤
	*/
	public function setEffectEvent(eventType:String , eventAction:String , eventLabel:String):Void{
		eventObject[eventType] = function(){
			effect_mc[eventAction]( eventLabel );
		}
	}
	
	/**
	* 設定影片片段的連結網址
	*
	* @param  eventType		事件的種類，可接受的參數為
	*						"onRelease" ， "onRollOut" ， "onRollOver" 等
	* @param  linkURL		連結的網址，同getURL()
	* @param  linkWindow	連結網址的視窗，同getURL() 
	* 						可接受的參數為 "_self" ， "_blank" ， "_parent" ， "_top" 
	*/
	public function setLink(eventType:String , linkURL:String , linkWindow:String):Void{
		//儲存 URL 到主影片，避免 URL 無法存取或存取"錯誤"
		container_mc.linkURL = linkURL ;
		
		eventObject[eventType] = function(){
			getURL(this.linkURL , linkWindow );
		}
	}

	/**
	* 在圖片讀取完畢後 (onLoadInit) ， 指派事件處理函式
	*/
	private function assignEvents():Void{
		var event ;
		for( event in eventObject){
			container_mc[event] = eventObject[event] ;
		}
	}

	/**
	* 在圖片讀取完畢後 (onLoadInit) ，建立特效影片片段的實體
	*/
	private function createEffect():Void{
		var mc : MovieClip ;
		if(!effectMethod)
			return ;
		if(effectMethod == "attach"){
			mc = container_mc.attachMovie( effectID , "effect_mc" , effectDepth );
		}
		else if(effectMethod == "load"){
			container_mc.loadMovie(effectPath);
		}
		effect_mc = mc;
	}
}