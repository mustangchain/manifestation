// Default Truffle setup.
var Migrations = artifacts.require("./Migrations.sol");

module.exports = function(deployer) {
	deployer.deploy(Migrations);
};
