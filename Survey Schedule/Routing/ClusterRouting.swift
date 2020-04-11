//
//  ClusterRouting.swift
//  Survey Schedule
//
//  Created by Jasper Hsieh on 3/23/20.
//  Copyright © 2020 Jasper Hsieh. All rights reserved.
//

import Foundation
import SwiftyJSON

class ClusterRouting{
    var clusterStartId = 100

    //var clusterInfo: JSON
    var workingTime: Int // second
    //let dataUtil: DataUtil
    let stationRouting: StationRouting

    init(clusterInfo: JSON, workingTime: Int){
        //self.clusterInfo = clusterInfo
        self.workingTime = workingTime * 60 * 60
        //self.dataUtil = DataUtil()
        self.stationRouting = StationRouting()
    }

    func getCompleteSchedule(info clusterInfo: JSON, workingHour: Int, currentStat: String) -> [[VisitLog]]{
        //let statInfo = DataUtil.statInfo
        //var clusterVisit = DataUtil.clusterInfo!
        var clusterVisit = resetVisitedStatus(jsonObj: clusterInfo)
        let workingTime = workingHour * 60 * 60

        let startTime = 0
        var preStat = currentStat
        // Check the station isRevisit status while currentStat != CS25
        var visitPath: [VisitLog] = [VisitLog(stat: preStat, timestamp: startTime, isRevisit: false)]
        var day = 1
        var schedule: [[VisitLog]] = []

        print("getNextDaySchedule \(workingTime)")

        while true {

            // choose the closest cluster from preStat
            var nextCluster = "-1"
            var minTime = Int.max
            //print(clusterVisit)
            for (cluster, _) in clusterVisit {
                if !clusterVisit[cluster]["visited"].bool! {
                    //print("Checking cluster \(cluster)")
                    let travelTime = getStatsTravelTime(stat1: preStat, stat2: clusterVisit[cluster]["start"].string!)
                    if travelTime < minTime {
                        minTime = travelTime
                        nextCluster = cluster
                        //print("nextCluster \(nextCluster) \(minTime)")
                    }
                }
            }
            if nextCluster == "-1" {
                print("Something wrong wiht finding next cluster")
                break
            }

            // Check if we finish next cluster in time
            print()
            print("*** Checking cluster \(nextCluster) ***")
            //var nextClusterVisitPath = stationRouting.getVisitPath(statList: clusterVisit[nextCluster]["stations"].arrayObject as! [String], pathSoFar: visitPath)
            var nextClusterVisitPath = stationRouting.getVisitPath(statList: clusterVisit[nextCluster]["stations"].arrayObject as! [String], pathSoFar: visitPath, cluster: nextCluster)
            let nextClusterLastVisitLog = nextClusterVisitPath.last!
            let nextClusterFinishTime = nextClusterLastVisitLog.timestamp + getStatsTravelTime(stat1: nextClusterLastVisitLog.station, stat2: BaseStation)

            if nextClusterFinishTime > workingTime {
                // Exceed workingTime today, cut cluster
                print("Exceed workingTime limit, check cutting cluster")
                for i in (0..<nextClusterVisitPath.count).reversed() {
                    let log = nextClusterVisitPath[i]
                    if log.isRevisit {
                        print("Ignore repeat station")
                        continue
                    }
                    let timeToFinish = log.timestamp + getStatsTravelTime(stat1: log.station, stat2: BaseStation)
                    //print("Checking \()")
                    print("Checking last station \(log.station) \(timeToFinish)")
                    if timeToFinish < workingTime {
                        // Form new cluster from left stations
                        print("Cut cluster")
                        let newCluster = String(clusterStartId)
                        clusterStartId += 1
                        clusterVisit[newCluster] = JSON()
                        clusterVisit[newCluster]["visited"] = false
                        var remainStats: [String] = []
                        for visitLog in Array(nextClusterVisitPath[(i+1)...]) {
                            remainStats.append(visitLog.station)
                        }
                        print("RemainStats: \(remainStats)")
                        clusterVisit[newCluster]["stations"] = JSON(remainStats)
                        clusterVisit[newCluster]["start"] = JSON(stationRouting.getStartStat(statList: remainStats))

                        // Update cluster info
                        clusterVisit[nextCluster]["visited"] = true
                        nextClusterVisitPath.removeSubrange((i+1)...)
                        print("Visit next cluster on", terminator: "")
                        VisitLog.dumpPath(path: nextClusterVisitPath)
                        visitPath.append(contentsOf: nextClusterVisitPath)
                        preStat = log.station
                        break
                    }
                }
            }else {
                // Add next cluster visited path
                print("Go to cluster \(nextCluster)")
                clusterVisit[nextCluster]["visited"] = true
                visitPath.append(contentsOf: nextClusterVisitPath)
                preStat = nextClusterLastVisitLog.station
            }

            VisitLog.dumpPath(path: visitPath)

            // Reset path value when done today
            if visitedAll(jsonObj: clusterVisit) || (nextClusterFinishTime > workingTime) {
                print("----- Day \(day) done -----")
                print()

                //scheduleDic[day] = visitPath
                schedule.append(visitPath)

                preStat = BaseStation
                visitPath = [VisitLog(stat: BaseStation, timestamp: startTime, isRevisit: false)]
                day += 1
                stationRouting.resetRepeatTime()
                if visitedAll(jsonObj: clusterVisit) {
                    break
                }
                //print(clusterVisit)
            }
        }
        return schedule
    }

    func visitedAll(jsonObj: JSON) -> Bool{
        for (k, _) in jsonObj{
            //var tmp = jsonObj[k]["visited"]
            //print(tmp)
            if jsonObj[k]["visited"] == false {
                //print("\(k) hasn't visited")
                return false
            }
        }
        print("All clusters has been visited")
        return true
    }

    func resetVisitedStatus(jsonObj: JSON) -> JSON{
        var jsonObjVisit: JSON = jsonObj
        for (k, _) in jsonObj{
            jsonObjVisit[k]["visited"] = false
        }
        //print(jsonObjVisit)
        return jsonObjVisit
    }
}
