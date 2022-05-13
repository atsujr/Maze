//
//  ViewController.swift
//  Maze
//
//  Created by Atsuhiro Muroyama on 2022/05/09.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    var playerView: UIView!
    var playerMotionManager: CMMotionManager!
    var speedX: Double = 0.0
    var speedY: Double = 0.0
    
    //画面サイズの取得
    let screenSize = UIScreen.main.bounds.size
    
    let maze = [
    [1, 0, 0, 0, 1, 0],
    [1, 0, 1, 0, 1, 0],
    [3, 0, 1, 0, 1, 0],
    [1, 1, 1, 0, 0, 0],
    [1, 0, 0, 1, 1, 0],
    [0, 0, 1, 0, 0, 0],
    [0, 1, 1, 0, 1, 0],
    [0, 0, 0, 0, 1, 1],
    [0, 1, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 2],]
    var startView: UIView!
    var goalView: UIView!
    //walliewのフレームの情報を入れておく配列
    var wallRectArray = [CGRect]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let cellWidth = screenSize.width / CGFloat(maze[0].count)
        let cellHeight = screenSize.height / CGFloat(maze.count)
        
        let cellOffsetX = cellWidth / 2
        let cellOffsetY = cellHeight / 2
        for y in 0 ..< maze.count{
            for x in 0 ..< maze[y].count{
                switch maze[y][x] {
                case 1://あたるとゲームオーバー
                    let wallView = createview(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    wallView.backgroundColor = UIColor.black
                    view.addSubview(wallView)
                    wallRectArray.append(wallView.frame)
                case 2://start地点
                    startView = createview(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    startView.backgroundColor = UIColor.green
                    view.addSubview(startView)
                case 3://goal
                    goalView = createview(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    goalView.backgroundColor = UIColor.red
                    view.addSubview(goalView)
                default:
                    break
                }
            }
        }
        //playerviewを作る
        playerView = UIView(frame: CGRect(x:0, y:0, width: cellWidth / 6, height: cellHeight / 6))
        playerView.center = startView.center
        playerView.backgroundColor = UIColor.gray
        view.addSubview(playerView)
        
        //motionmanagerを作る
        playerMotionManager = CMMotionManager()
        playerMotionManager.accelerometerUpdateInterval = 0.02
        
        startAccelerometer()
    }
    func createview(x: Int, y: Int, width: CGFloat, height: CGFloat, offsetX: CGFloat, offsetY: CGFloat) -> UIView{
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let view = UIView(frame: rect)
        
        let center = CGPoint(x: offsetX + width * CGFloat(x), y: offsetY + height * CGFloat(y))
        
        view.center = center
        
        return view
    }
    func startAccelerometer(){
        //加速度を取得
        let handler: CMAccelerometerHandler = {(CMAccelerometerData: CMAccelerometerData?, error: Error?) -> Void in
            self.speedX += CMAccelerometerData!.acceleration.x
            self.speedY += CMAccelerometerData!.acceleration.y
        //プレーヤーの中心位置を設定
            var posX = self.playerView.center.x + (CGFloat(self.speedX) / 3)
            var posY = self.playerView.center.y - (CGFloat(self.speedY) / 3)
        //画面からはみ出そうなときにposXとposYを修正
            if posX <= self.playerView.frame.width / 2 {
                self.speedX = 0
                posX = self.playerView.frame.width / 2
            }
            if posY <= self.playerView.frame.height / 2 {
                self.speedY = 0
                posY = self.playerView.frame.height / 2
            }
            if posX >= self.screenSize.width - (self.playerView.frame.width / 2){
                self.speedX = 0
                posX = self.screenSize.width - (self.playerView.frame.width / 2)
            }
            if posY >= self.screenSize.height - (self.playerView.frame.height / 2){
                self.speedY = 0
                posY = self.screenSize.height - (self.playerView.frame.height / 2)
            }
            for wallRect in self.wallRectArray {
                if wallRect.intersects(self.playerView.frame){
                    self.gameCheck(result: "gameover", message: "壁に当たりました")
                    return
                }
            }
            if self.goalView.frame.intersects(self.playerView.frame){
                self.gameCheck(result: "clear", message: "クリアしました")
                return
            }
            self.playerView.center = CGPoint(x: posX, y: posY)
        }
        //加速度の開始
        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: handler)
    }
    func gameCheck(result: String, message: String){
        if playerMotionManager.isAccelerometerActive{
            playerMotionManager.stopAccelerometerUpdates()
        }
        let gameCheckAlert: UIAlertController = UIAlertController(title: result, message: message, preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: "もう一度", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.retry()
            
        
        })
        gameCheckAlert.addAction(retryAction)
        self.present(gameCheckAlert, animated: true, completion: nil)
    }
    func retry(){
        //プレーヤーの位置を初期化
        playerView.center = startView.center
        //加速度センサーを始める
        if !playerMotionManager.isAccelerometerActive{
            self.startAccelerometer()
        }
        speedX = 0.0
        speedY = 0.0
    }

}

