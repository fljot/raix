package raix.reactive.tests.operators.composition
{
	import org.flexunit.Assert;
	
	import raix.reactive.IObservable;
	import raix.reactive.Observable;
	import raix.reactive.Subject;
	import raix.reactive.tests.mocks.StatsObserver;
	import raix.reactive.tests.operators.AbsDecoratorOperatorFixture;
	
	[TestCase]
	public class PeekFixture extends AbsDecoratorOperatorFixture
	{
		protected override function createEmptyObservable(source:IObservable):IObservable
		{
			return source.peek(null);
		}
		
		[Test]
		public function next_action_is_called_before_observer() : void
		{
			var manObs : Subject = new Subject();
			
			var actionCalled : Boolean = false;
			var observerCalled : Boolean = false; 
			
			manObs
				.peek(function(pl:Object):void { Assert.assertFalse(observerCalled); actionCalled = true; })
				.subscribe(function(pl:Object):void { Assert.assertTrue(actionCalled); observerCalled = true; })
			
			manObs.onNext(0);
			
			Assert.assertTrue(actionCalled);
			Assert.assertTrue(observerCalled);
		}
		
		[Test]
		public function complete_action_is_called_before_observer() : void
		{
			var manObs : Subject = new Subject();
			
			var actionCalled : Boolean = false;
			var observerCalled : Boolean = false; 
			
			manObs
				.peek(null, function():void { Assert.assertFalse(observerCalled); actionCalled = true; })
				.subscribe(null, function():void { Assert.assertTrue(actionCalled); observerCalled = true; })
			
			manObs.onCompleted();
			
			Assert.assertTrue(actionCalled);
			Assert.assertTrue(observerCalled);
		}
		
		[Test]
		public function error_action_is_called_before_observer() : void
		{
			var manObs : Subject = new Subject();
			
			var actionCalled : Boolean = false;
			var observerCalled : Boolean = false; 
			
			manObs
				.peek(null, null, function(pl:Error):void { Assert.assertFalse(observerCalled); actionCalled = true; })
				.subscribe(null, null, function(pl:Error):void { Assert.assertTrue(actionCalled); observerCalled = true; })
			
			manObs.onError(new Error());
			
			Assert.assertTrue(actionCalled);
			Assert.assertTrue(observerCalled);
		}
		
		[Test]
		public function error_thrown_in_next_action_is_sent_to_on_error_if_only_next_is_specified() : void
		{
			var stats : StatsObserver = new StatsObserver();
			
			Observable.range(0, 3)
				.peek(function(pl:Object):void { throw new Error(); })
				.subscribeWith(stats)
			
			Assert.assertTrue(stats.errorCalled);
		}
		
		[Test]
		public function error_thrown_in_next_action_is_sent_to_on_error_if_next_and_complete_is_specified() : void
		{
			var stats : StatsObserver = new StatsObserver();
			
			Observable.range(0, 3)
				.peek(
					function(pl:Object):void { throw new Error(); }, 
					function():void{})
				.subscribeWith(stats)
			
			Assert.assertTrue(stats.errorCalled);
		}
		
		[Test]
		public function error_thrown_in_next_action_is_bubbled_if_next_and_error_is_specified() : void
		{
			var stats : StatsObserver = new StatsObserver();
			
			Observable.range(0, 3)
				.peek(
					function(pl:Object):void { throw new Error(); }, 
					null, 
					function(e:Error):void{})
				.subscribeWith(stats)
			
			Assert.assertTrue(stats.errorCalled);
		}
		
		[Test]
		public function error_thrown_in_next_action_is_bubbled_if_all_actions_are_specified() : void
		{
			var stats : StatsObserver = new StatsObserver();
			
			Observable.range(0, 3)
				.peek(
					function(pl:Object):void { throw new Error(); }, 
					function():void{}, 
					function(e:Error):void{})
				.subscribeWith(stats)
			
			Assert.assertTrue(stats.errorCalled);
		}
		
		[Test(expects="Error")]
		public function errors_thrown_by_subscriber_are_bubbled() : void
		{
			var manObs : Subject = new Subject();
			
			var obs : IObservable = manObs.map(function(pl:uint) : Boolean
			{
				return true;
			});
			
			obs.subscribe(
				function(pl:int):void { throw new Error(); },
				function():void { },
				function(e:Error):void { Assert.fail("Unexpected call to onError"); }
			);

			manObs.onNext(0);
		}
	}
}