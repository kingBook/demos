﻿package  {
	
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.text.TextField;
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.utils.getTimer;
	import flash.events.MouseEvent;
	
	public class Draw extends MovieClip {
		
		private var _txt:TextField;
		private var _mc:MovieClip;
		
		private var _sourceBmd:BitmapData;
		private var _canvasBmd:BitmapData;
		private var _canvasBmp:Bitmap;
		private var _canvasShape:Shape;
		
		
		
		public function Draw() {
			if(stage)init();
			else addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		private function init(e:Event=null):void{
			if(e)removeEventListener(Event.ADDED_TO_STAGE,init);
			//
			_txt=getChildByName("txt") as TextField;
			_txt.text="0%";
			_mc=getChildByName("mc") as MovieClip;
			_mc.visible=false;
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownHandler);
			addEventListener(Event.ENTER_FRAME,update);
		}
		
		private function onMouseDownHandler(e:MouseEvent):void{
			if(_sourceBmd==null&&_canvasBmd==null){
				initDraw(_mc);
			}
		}
		
		private function initDraw(child:DisplayObject):void{
			var childRect:Rectangle=child.getBounds(child.parent);
			var childId:int=child.parent.getChildIndex(child);
			var childParent:DisplayObjectContainer=child.parent;
			
			_sourceBmd=getDisObjBmd(child);
			_canvasBmd=_sourceBmd.clone();
			//addChild(new Bitmap(_sourceBmd));
			_canvasBmp = new Bitmap(_canvasBmd);
			_canvasBmp.x=childRect.x;
			_canvasBmp.y=childRect.y;
			childParent.addChildAt(_canvasBmp,childId);
			childParent.removeChild(child);

			_canvasShape = new Shape();
			_canvasShape.x = childRect.x;
			_canvasShape.y = childRect.y;
			_canvasShape.visible=false;
			childParent.addChild(_canvasShape);

			_canvasShape.graphics.lineStyle(40);
			_canvasShape.graphics.lineBitmapStyle(_sourceBmd);
			_canvasShape.graphics.moveTo(_canvasShape.mouseX,_canvasShape.mouseY);
			
		}
		
		//var time:int
		private function update(e:Event):void{
			if(_sourceBmd&&_canvasBmd){
				_canvasShape.graphics.lineTo(_canvasShape.mouseX,_canvasShape.mouseY);
				_canvasBmd.fillRect(_canvasBmd.rect,0);//清空再画，否则有透明度的效果会叠加覆盖
				_canvasBmd.draw(_canvasShape);
				//time=flash.utils.getTimer();
				var rate:Number = checkBmd(_sourceBmd,_canvasBmd);
				//time=getTimer()-time;
				//trace(time);
				_txt.text = int(rate*100)+"%";
			}
		}

		private function checkBmd(sourceBmd:BitmapData,canvasBmd:BitmapData):Number{
			var sourceCount:int, canvasCount:int;
			for(var i:int=0; i<=sourceBmd.width; i++){
			for(var j:int=0; j<=sourceBmd.height; j++){
				if(sourceBmd.getPixel32(i,j)) sourceCount++;
				if(canvasBmd.getPixel32(i,j)) canvasCount++;
			}}
			return canvasCount/sourceCount;
		}

		private function getDisObjBmd(disObj:DisplayObject):BitmapData{
			var r:Rectangle = disObj.getBounds(disObj);
			var bmd:BitmapData = new BitmapData(r.width,r.height,true,0);
			var matrix:Matrix = new Matrix(1,0,0,1,-r.x,-r.y);
			bmd.draw(disObj,matrix);
			return bmd;
		}
		
		private function dispose():void{
			if(_sourceBmd){
				_sourceBmd.dispose();
				_sourceBmd=null;
			}
			if(_canvasBmp){
				if(_canvasBmp.parent)_canvasBmp.parent.removeChild(_canvasBmp);
				_canvasBmp=null;
			}
			if(_canvasBmd){
				_canvasBmd.dispose();
				_canvasBmd=null;
			}
			if(_canvasShape){
				if(_canvasShape.parent)_canvasShape.parent.removeChild(_canvasShape);
				_canvasShape=null;
			}
		}
		
		
	}
}
