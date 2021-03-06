package raix.reactive.tests.operators.filter
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	
	import org.flexunit.Assert;
	
	import raix.reactive.IObservable;
	import raix.reactive.Subject;
	import raix.reactive.tests.mocks.StatsObserver;
	import raix.reactive.tests.operators.AbsDecoratorOperatorFixture;
	
	public class OfClassFixture extends AbsDecoratorOperatorFixture
	{
		protected override function createEmptyObservable(source:IObservable):IObservable
		{
			return source.ofClass(Object);
		}
		
		[Test]
		public function excludes_incompatible_types() : void
		{
			var manObs : Subject = new Subject();
			
			var obs : IObservable = manObs.ofClass(DisplayObject);
			
			var stats : StatsObserver = new StatsObserver();
			
			obs.subscribeWith(stats);
			
			var tfA : TextField = new TextField();
			var tfB : TextField = new TextField();
			
			manObs.onNext(tfA);
			manObs.onNext(new EventDispatcher());
			manObs.onNext(tfB);
			manObs.onNext(new EventDispatcher());
			
			Assert.assertEquals(2, stats.nextCount);
			Assert.assertStrictlyEquals(tfA, stats.nextValues[0]);
			Assert.assertStrictlyEquals(tfB, stats.nextValues[1]);
		}
		
		[Test(expects="Error")]
		public function errors_thrown_by_subscriber_are_bubbled() : void
		{
			var manObs : Subject = new Subject();
			
			var obs : IObservable = createEmptyObservable(obs);
			
			obs.subscribe(
				function(pl:int):void { throw new Error(); },
				function():void { },
				function(e:Error):void { Assert.fail("Unexpected call to onError"); }
			);

			manObs.onNext(0);
		}

	}
}