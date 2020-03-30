/**********************************
* MultiClipSlider ， 影片移動過場效果
*
* @id		: MultiClipSlider
* @author	: Swings Huang (E-mail:silverwings999@hotmail.com)
* @version	: 1.0.0
***********************************/

class MultiClipSlider {
	// 將包含所有資產的影片片段
	private var container_mc:MovieClip;
	// 將附加container_mc的影片片段
	private var target_mc:MovieClip;
	
	// 效果預設的移動速度
	private var default_speed : Number ;
	// 效果預設的移動距離
	private var default_distance : Number ;
	// 過場效果間隔
	private var default_interval : Number ;
	
	// 影片片段深度設置
	private var containerDepth:Number;  
	private static var current_depth : Number = -1 ;

	// 陣列參照, 儲存所有滑動影片片段的成員
	public static var arr_slide_mcs = new Array();
	// 陣列參照, 儲存所有 ImageViewerExtra物件
	private var arr_slide_objs = new Array();
	// 圖片位址
	private var arr_slide_srcs = new Array();
	// 圖片座標設定之物件
	public static var arr_slide_coord = new Array() ;
	
	public static var current_mc_id :Number= -1 ;
	
	private static var total_slide : Number ;
	public static var current_vid : Number ;
	
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
	public function MultiClipSlider (target:MovieClip,depth:Number ,x :Number, y:Number ) {
		// 指派屬性值
    	target_mc = target;
    	containerDepth = depth;

    	// 創造這個MultiClipSlider的視覺資產容器
		createMainContainer(x,y);
	}
	public function pushImageViewr(	src : String , startX:Number ,endX:Number ,startY:Number , endY:Number){
		// 創造該滑動片段的父影片
		var myMC : MovieClip = createImageClip(startX,startY);
		// 創造 ImageViewerExtra物件 , mc , d , x,y,w,h, borderthick , bordercolor
		var ive : ImageViewerExtra = new ImageViewerExtra( myMC, 0 , 0 , 0 , -1 , -1, 0, 0);
		
		//設置座標
		createCoordinateObject( startX, endX, startY , endY );
		
		// 儲存資訊
		arr_slide_mcs.push(myMC);
		arr_slide_objs.push(ive);
		arr_slide_srcs.push(src);
		total_slide = arr_slide_mcs.length ;
	}
	public function createCoordinateObject(sx:Number,ex:Number,sy:Number,ey:Number){
		var o : Object = new Object({ start_x :sx ,
									start_y :sy ,
									end_x : ex,
									end_y : ey });
		// getCurrentCoord
		var arr_coords : Array ;
		arr_coords = getCurrentCoord() ;
		arr_coords = (arr_coords == undefined) ? new Array() : arr_coords ;
		
		var coord_i : Number = arr_coords.length ;
		
		//存入新的座標設定值
		arr_coords.push( o );
		
		//存入或覆蓋所有座標組設定
		setCurrentCoord( arr_coords );
	}
	// 取得目前的座標"設定組"
	private function getCurrentCoord(){
		return arr_slide_coord[ current_mc_id ] ;
	}
	// 儲存目前的座標"設定組"
	private function setCurrentCoord( arr_coordset : Array ):Void{
		arr_slide_coord[ current_mc_id ] = arr_coordset;
	}

	public function startAllSlide():Void{
		//重頭開始
		var i :Number = current_mc_id = 0 ;
		var viewer : ImageViewerExtra  ;
		var src : String  ;
		var mc : MovieClip ;
		
		for( ; i < countTotalSlide() ; i++){
			viewer = arr_slide_objs[ i ];
			src = arr_slide_srcs[ i ];
			mc = arr_slide_mcs[ i ]
			viewer.loadImage( src );
			mc._visible = false ;
		}
		startSlide( );
	}
	public static function startSlide():Void{
		var mc : MovieClip = arr_slide_mcs[ current_mc_id ];
		var start_x : Number = arr_slide_coord[ current_mc_id ][0].start_x ;
		var start_y : Number = arr_slide_coord[ current_mc_id ][0].start_y ;
		var end_x : Number = arr_slide_coord[ current_mc_id ][0].end_x ;
		var end_y : Number = arr_slide_coord[ current_mc_id ][0].end_y ;
		var x_is_incre : Boolean = end_x > start_x ? true : false ;
		var y_is_incre : Boolean = end_y > start_y ? true : false ;
		// set to start
		mc._visible = true ;
		setProperty( mc, _x , start_x );
		setProperty( mc, _y , start_y );
		current_vid = setInterval(intervalMove ,60 ,mc ,end_x ,end_y ,x_is_incre,y_is_incre , 1 );
	}
	public static function nextSlide():Void{
		clearInterval(current_vid);
		arr_slide_mcs[ current_mc_id ]._visible = false ;
		
		current_mc_id = current_mc_id + 1 ;
		current_mc_id = current_mc_id >= countTotalSlide() ? 0 : current_mc_id ; //Overflow Check
		
		MultiClipSlider.startSlide();
	}
	// 失控的 Interval
	public static function intervalMove(mc:MovieClip,end_x:Number,end_y:Number,
								  x_incre:Boolean, y_incre:Boolean , dist:Number){
		var ec : Number = 0 ;
		var new_x : Number = mc._x ;
		var new_y : Number = mc._y;
		if( x_incre && mc._x < end_x )
			new_x = mc._x + dist ;
		else if( (!x_incre) && mc._x > end_x )
			new_x = mc._x - dist ;
		else
			ec++;
		if( y_incre && mc._y < end_y )
			new_y = mc._y + dist ;
		else if( (!y_incre) && mc._y > end_y )
			new_y = mc._y - dist ;
		else
			ec++;
		trace(new_x+":"+new_y);
		// Assign
		setProperty( mc, _x , new_x );
		setProperty( mc, _y , new_y );
		// Ending
		if(ec >= 2)
			MultiClipSlider.nextSlide();
	}
	/**
	* 建立一個用來包含MultiClipSlider視覺資產的 
	* container_mc影片片段。
	*
	* @param   x   container_mc影片片段的水平座標 
	* @param   y   container_mc影片片段的垂直座標
	*/
	private function createImageClip( x : Number , y : Number):MovieClip{
		current_mc_id++ ;
		current_depth++ ;
		var mc : MovieClip = container_mc.createEmptyMovieClip("clip_mc_" + current_mc_id, current_depth);
		setProperty( mc,_x , x );
		setProperty( mc,_y , y );
		return mc ;
	}
	/**
	* 建立一個用來包含MultiClipSlider視覺資產的 
	* container_mc影片片段。
	*
	* @param   x   container_mc影片片段的水平座標 
	* @param   y   container_mc影片片段的垂直座標
	*/
	private function createMainContainer (x:Number, y:Number):Void {
    	container_mc = target_mc.createEmptyMovieClip(
                                           "slider_mc" + containerDepth, 
                                           containerDepth);
		container_mc._x = x;
		container_mc._y = y;
	}
	public function getCurrentVID():Number{
		return current_vid ;
	}
	public static function countTotalSlide():Number{
		return total_slide ;
	}
}