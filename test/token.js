var Token = artifacts.require("./Token.sol");


contract('Token', function(accounts) {

	// The first account was used to deploy the token contract.
	const creator = accounts[0];

	// traditional test accounts
	const alice = accounts[1], bob = accounts[2], carol = accounts[3];

	before(async () => {
		var t = await Token.new();
		assert.equal((await t.balanceOf(creator)).toNumber(), 100E9, "creator's initial balance");
		assert.equal((await t.balanceOf(alice)).toNumber(), 0, "Alice's initial balance");
		assert.equal((await t.balanceOf(bob)).toNumber(), 0, "Bob's initial balance");
		assert.equal((await t.balanceOf(carol)).toNumber(), 0, "Carol's initial balance");
	});

	it("labels", async () => {
		var t = await Token.new();
		assert.equal(await t.name(), 'MustangChain Token', "token name");
		assert.equal(await t.symbol(), 'MUST', "token symbol");
		assert.equal((await t.decimals()).toNumber(), 0, "decimal count");
		assert.equal((await t.totalSupply()).toNumber(), 100E9, "token count");
	});

	it("transfers", async () => {
		var t = await Token.new();

		await t.transfer(alice, 1001);
		assert.equal((await t.balanceOf(alice)).toNumber(), 1001, "Alice's balance");
		assert.equal((await t.balanceOf(creator)).toNumber(), 100E9 - 1001, "Creator's balance after Alice");

		await t.transfer(bob, 99);
		assert.equal((await t.balanceOf(bob)).toNumber(), 99, "Bob's balance");
		assert.equal((await t.balanceOf(creator)).toNumber(), 100E9 - 1001 - 99, "Creator's balance after Alice and Bob");

		await t.transfer(bob, 1, {from: alice});
		assert.equal((await t.balanceOf(alice)).toNumber(), 1000, "Alice's balance");
		assert.equal((await t.balanceOf(bob)).toNumber(), 100, "Bob's balance");
	});

	it("transfer limits", async () => {
		var t = await Token.new();

		try {
			await t.transfer(bob, 1, {from: carol});
			assert.fail("spend without funds");
		} catch {}

		await t.transfer(carol, 2);
		try {
			await t.transfer(bob, 3, {from: carol});
			assert.fail("overspend");
		} catch {}

		// transfer all
		await t.transfer(bob, 1, {from: carol});

		// zero transfers are allowed
		await t.transfer(bob, 0, {from: carol});
	});

	it("transfer from", async () => {
		var t = await Token.new();

		// Bob may spend 60 tokens from creator
		await t.approve(bob, 60, {from: creator});
		assert.equal((await t.allowance(creator, bob)).toNumber(), 60, "Bob's allowance");

		// Bob withdraws 42
		await t.transferFrom(creator, bob, 42, {from: bob});
		assert.equal((await t.allowance(creator, bob)).toNumber(), 18, "Bob's remaining allowance");

		// Alice tries too
		try {
			await t.transferFrom(creator, bob, 1, {from: alice});
			assert.fail("Alice spend without allowance");
		} catch {}

		// Bob tries again
		try {
			await t.transferFrom(creator, bob, 42, {from: bob});
			assert.fail("Bob overspend his allowance");
		} catch {}

		// Bob shares remainder
		t.transferFrom(creator, alice, 18, {from: bob});
		assert.equal((await t.allowance(creator, bob)).toNumber(), 0, "Bob's final allowance");
	});

});
