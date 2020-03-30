/******************************************
*	ID	:	Calendar.as v1.0
*	Licence	:	Swings (C) Taiwan , silverwings999@hotmail.com
*	Date	:	2007.08.20
*******************************************/

class Calendar extends Date{
	public var year : Number ;
	public var month : Number ;
	public var day : Number ;
	public var week : Number ;
	
	// Week Data of Year
	private var wyear : Array = new Array();
	// Week Data of Month
	private var wmonth : Array = new Array();
	// Week Data of Day
	private var wday : Array = new Array();
	
	private var arr_mday = new Array(30,27,30,29,30,29,30,30,29,30,29,30);
	// constructor
	function Calendar(){
		// Super ,  year , month , day
		super(arguments[0],arguments[1]-1,arguments[2]-1);
		
		// OverLoad
		year = arguments[0] ;
		month = arguments[1]-1 ;
		day = arguments[2]-1 ;
		week = this.getDay();
		
		if(isLeapYear())
			arr_mday[1] = 28 ;
	}
	public function nextWeek():Void{
		
	}
	public function backWeek():Void{

	}
	// This method will return Sunday
	public function setWeekData():Void{
		var i : Number ;
		
		// Set Current 
		var curDay = this.day ;
		var curMonth = this.month ;
		var curYear = this.year ;
		var tempCount : Number ;
		
		// Set First Day Of Week
		// The day across month , myDay is negative
		if ( ( day = day - week) < 0 ){
			curDay = 0 ;
			tempCount = (-day) +1 ;
			//trace("這週有"+(tempCount)+"天在上個月度過");
			// If month across year , month is negative
			if( --month < 0 ){
				month = arr_mday.length - 1 ;
				// ReSet Year
				--year;
			}
			// If month not across year , myMonth is positive
			//no Need to Reset Year
			else{			}				
				day = arr_mday[ month ] + day;
		}
		// no Need to Reset Year & Month & Day
		else{
			tempCount = 0 ;
			curDay = day = day - week ;
			// month = month ; year = year ;
		}
				
		var i : Number = 0 ;
		// Across 
		for( ; i < tempCount ; i++ ){
			wday[i] = day + i ;
			wmonth[i] = month ;
			wyear[i] = year ;
		}
		// Not Across 
		for( ; i < 7 ; i++ ){
			wday[i] = curDay++ ;
			wmonth[i] = curMonth ;
			wyear[i] = curYear ;
		}
		
		//trace(wday);trace(wmonth);trace(wyear);
		//trace("本周的第一天是:"+year+'年'+(month+1)+'月'+(day+1)+'日');
	}
	
	public function getWeekDays():Array{
		return wday ;
	}
	
	public function getWeekMonths():Array{
		return wmonth ;
	}
	
	public function getWeekYears():Array{
		return wyear ;
	}
	private function isLeapYear():Boolean{
		return (year % 400 == 0) or ( ((year % 4)==0) and ((year % 100)!=0) ) ?
			true : false ;
	}
	
}