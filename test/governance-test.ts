import { expect } from "chai";
import { ethers, deployments, network } from 'hardhat';
import { Demo, Governance } from '../typechain-types'; //stegh sxal atali bayc compile is heto kdzvi qani vor karajan inch anhrajeshta

describe('MShop', function() {
  let governance: Governance;
  let demo: Demo;

  //bolor patmutyuny deploy enq anum
  beforeEach(async function() {
    await deployments.fixture(['MyToken', 'Governance', 'Demo']);

    governance = await ethers.getContract<Governance>('Governance');//dostup enq stanum Gov contractin
    demo = await ethers.getContract<Demo>('Demo'); //dostup enq stanum Demo contractin
  });

  //takinov nor proposal enq dnum golosi arajark
  it("works", async function() {
    const proposeTx = await governance.propose(
      demo.address, //asum enq vor demo-i 
      10, //hasceyin uzum enq ugharkel 10wei
      "pay(string)", //kanchenq pay func-y string arg-ov
      ethers.utils.defaultAbiCoder.encode(['string'], ['test']), //chisht dzevov kodavorum enq soobsheniya test-y vory stringa
      "Sample proposal" //es el nkaragrutyunna
    );

    const proposalData = await proposeTx.wait(); //spasum enq tx lini

    const proposalId = proposalData.events?.[0].args?.proposalId.toString();//stanum enq prop ID-n, sobitiayic

    //heto ugharkum enq governancin 10wei vor prosto yndegh inch vor pogh lini, te che works -i 19 weiy vorteghic
    const sendTx = await ethers.provider.getSigner(0).sendTransaction({
      to: governance.address,
      value: 10
    });
    await sendTx.wait();

    await network.provider.send("evm_increaseTime", [11]); // miqich jamanak enq anckacnum vor golosy sksi

    const voteTx = await governance.vote(proposalId, 1); //heto asum enq vro golos enq anum ed Id-ov prop ev golsi tesaky 1 za, qani vor arajin uchetniy zapisic eqn ashkhatum vor deploy a arel tokeny uremn sagh tokenn hzorutyunnery iranna 
    await voteTx.wait();

    await network.provider.send("evm_increaseTime", [70]); // eli enq jamanaky mecacnumm vor golosy avartvi
//asum enq executy ara qvearkvacy
    const executeTx = await governance.execute(
      demo.address,
      10,
      "pay(string)",
      ethers.utils.defaultAbiCoder.encode(['string'], ['test']),
      ethers.utils.solidityKeccak256(['string'], ["Sample proposal"])//baci verevi sagh arg eric talis enq sample pro-i hash -y
    );

    await executeTx.wait(); //spasum enq lini

    expect(await demo.message()).to.eq("test"); //stugum  enq vor  Demo ustanovilos soobsheniye znacheniyem test
    expect(await demo.balances(governance.address)).to.eq(10); //stugum enq vor gov-ic ekela 10 wei goveric voch te im acc-ic, vortev msg.sender governa u sagh tx-nery gnumen iranic
  });
});