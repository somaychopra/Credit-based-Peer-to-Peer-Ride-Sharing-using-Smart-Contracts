// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Carpool_algo {

    uint256 number;
    uint256 V = 11;
    uint256 INT_MAX = 100000;
    uint256[11][] graph;
    uint256[][11] paths;
    uint256[] opt_path;
    struct Drivers {
        uint256 start;
        uint256 end;
        uint256 seats;
        uint256 tokens;
    }
    struct Riders {
        uint256 start;
        uint256 end;
        uint256 tokens;
    }
    struct PlanNode {
        uint256 nodeId;
        int256 riderId;
        uint256 pick;
        uint256 visited;
    }
    struct Plans {
        PlanNode[] planNode;
        uint256[] allRiders;
    }
    Drivers[] drivers;
    Riders[] riders;
    Plans[] plans;
    
    function minDistance(uint256[] memory _dist, uint256[] memory _sptSet) public view returns(uint256) {
        uint256 min = INT_MAX;
        uint256 min_index;
        for (uint256 v = 0; v < V; v++) {
            if (_sptSet[v] == 0 && _dist[v] <= min) {
                min = _dist[v];
                min_index = v;      
            }
        }
        return min_index;
    }
    
    function printPath(int256[] memory _parent, uint256 j, uint256 end) public {
        int256 x = -1;
        if (parent[j] == x)
            return;
        printPath(_parent, uint256(_parent[j]), end);
        paths[end].push(j);
    }
    
    bool exists;
    uint256 dis = 0;
    uint256[] dist = new uint256[](V);
    uint256[] sptSet = new uint256[](V);
    int256[] parent = new int256[](V);
    uint256[] instEmpt;
    function dijkstra(uint256 src, uint256 end) public returns(uint256[] memory){
        dis = 0;
        for (uint256 i = 0; i < V; i++) {
            parent[src] = -1;
            dist[i] = INT_MAX;
            sptSet[i] = 0;
        }
        dist[src] = 0;
        for (uint256 count = 0; count < V - 1; count++)
        {
            uint256 u = minDistance(dist, sptSet);
            sptSet[u] = 1;
            for (uint256 v = 0; v < V; v++) {
                if (sptSet[v]== 0 && graph[u][v]>0 && dist[u] + graph[u][v] < dist[v]) {
                    parent[v] = int256(u);
                    dist[v] = dist[u] + graph[u][v];
                }    
            }
                 
        }
        delete paths;
        for(uint256 i=0;i<V;i++) {
            printPath(parent, i, i);
        }
        dis = dist[end];
        return paths[end];
    }
    
    function graphInit() public {
        graph.push([0, 5, 0, 0, 0, 0, 0, 0, 1, 0, 0]);//0
        graph.push([5, 0, 6, 0, 3, 0, 0, 0, 0, 0, 0]);//1
        graph.push([0, 6, 0, 4, 0, 3, 0, 0, 0, 0, 0]);//2
        graph.push([0, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0]);//3
        graph.push([0, 3, 0, 0, 0, 2, 0, 0, 0, 0, 0]);//4
        graph.push([0, 0, 3, 0, 2, 0, 2, 0, 0, 0, 0]);//5
        graph.push([0, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0]);//6
        graph.push([0, 0, 0, 4, 0, 0, 2, 0, 0, 0, 0]);//7
        graph.push([1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0]);//8
        graph.push([0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 3]);//9
        graph.push([0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0]);//10
    }
        
    uint256 min_path_tsp;
    uint256[] totPath;
    uint256[] segPath;
    uint256[] atemp;
    function permute(uint256[] memory a, uint256 l, uint256 r, uint256 start, uint256 end) public{
    	if (l == r) {
    	    delete atemp;
    	    atemp.push(start);
    	    for(uint256 i=0;i<a.length;i++) atemp.push(a[i]);
    	    atemp.push(end);
    	    uint256 current_pathweight = 0;
            uint256 k = atemp[0];
            delete totPath;
            exists = true;
            for (uint256 i = 1; i < atemp.length; i++) {
                dis = 0;
                delete segPath;
                segPath = dijkstra(k,atemp[i]);
                if(dis >= INT_MAX) exists = false;
                current_pathweight += dis;
                k = atemp[i];
                for(uint256 j=0;j<segPath.length;j++) {
                    totPath.push(segPath[j]);
                }
            }
            if(min_path_tsp>current_pathweight && exists) {
                min_path_tsp = current_pathweight;
                opt_path = totPath;
            }
    	}
    	else
    	{
    		for (uint256 i = l; i <= r; i++)
    		{
    		    uint256 temp = a[l];
    		    a[l] = a[i];
    		    a[i] = temp;
    			permute(a, l+1, r, start, end);
    			temp = a[l];
    			a[l] = a[i];
    			a[i] = temp;
    		}
    	}
    }

    uint256[] anodes;
    function tsp(uint256[] memory tspnodes) public {
        delete opt_path;
        delete anodes;
        
        uint256 n = tspnodes.length;
        for(uint256 i=1;i<n-1;i++) anodes.push(tspnodes[i]);
        min_path_tsp = INT_MAX;
        permute(anodes,0,anodes.length-1,tspnodes[0],tspnodes[n-1]);
    }
    
    Drivers dummyDriver;
    Riders dummyRider;
    function initiate() public {
        graphInit();
        dummyDriver.start = 0;
        dummyDriver.end = 3;
        dummyDriver.seats = 2;
        dummyDriver.tokens = 0;
        drivers.push(dummyDriver);
        dummyRider.start = 4;
        dummyRider.end = 5;
        dummyRider.tokens = 2;
        riders.push(dummyRider);
        dummyRider.start = 6;
        dummyRider.end = 7;
        dummyRider.tokens = 2;
        riders.push(dummyRider);
    }
    
    uint256[] sp;
    uint256[] assigned;
    uint256[] withinK;
    uint256[] nodes;
    PlanNode[] newplan;
    uint256[] endConsidered;
    Plans empPlan;
    uint256[] nextPath;
    uint256[] addedtonodes;
    function rideMatch() public {
        initiate();
        uint256 d = drivers.length;
        uint256 r = riders.length;
        assigned = new uint256[](r);
        addedtonodes = new uint256[](V);
        for(uint256 i=0;i<d;i++) plans.push(empPlan);
        for(uint256 i=0;i<r;i++) assigned[i] = 0;
        for(uint256 i=0;i<d;i++) {
            sp = dijkstra(drivers[i].start,drivers[i].end);
            uint256 spl = dis;
            uint256 maxDis = spl + spl/5;
            uint256 minDis = spl;
            uint256 current = drivers[i].start;
            uint256 k = (maxDis-minDis);
            uint256 covered_till = 0;
            while(current!=drivers[i].end && drivers[i].seats>0) {
                delete withinK;
                for(uint256 j=0;j<r;j++) {
                    if(assigned[j]==1) continue;
                    dijkstra(current,riders[j].start);
                    if(dis<=k) withinK.push(j);
                }
                int256 riderToPick = -1;
                uint256 _min = INT_MAX;
                delete nextPath;
                for(uint256 j=0;j<withinK.length;j++) {
                    
                    delete nodes;
                    for(uint256 x=0;x<V;x++) {
                        addedtonodes[x] = 0;
                    }
                    if(addedtonodes[current]==0) {
                        nodes.push(current);
                        addedtonodes[current] = 1;
                    }
                    for(uint256 l=0;l<plans[i].planNode.length;l++) {
                        if(((plans[i].planNode[l].riderId>=0 && plans[i].planNode[l].visited==0) || (plans[i].planNode[l].riderId>=0 && plans[i].planNode[l].nodeId==current)) &&
                                addedtonodes[riders[uint256(plans[i].planNode[l].riderId)].end]==0) {
                                    nodes.push(riders[uint256(plans[i].planNode[l].riderId)].end);
                                    addedtonodes[riders[uint256(plans[i].planNode[l].riderId)].end] = 1;
                                }
                    }
                    if(addedtonodes[riders[withinK[j]].start]==0) {
                        nodes.push(riders[withinK[j]].start);
                        addedtonodes[riders[withinK[j]].start] = 1;
                    }
                    if(addedtonodes[riders[withinK[j]].end]==0) {
                        nodes.push(riders[withinK[j]].end);
                        addedtonodes[riders[withinK[j]].end] = 1;
                    }
                    if(addedtonodes[drivers[i].end]==0) {
                        nodes.push(drivers[i].end);
                        addedtonodes[drivers[i].end] = 1;
                    }
                    tsp(nodes);
                    if(min_path_tsp<INT_MAX && min_path_tsp<_min && covered_till+min_path_tsp<=maxDis) {
                        _min = min_path_tsp;
                        riderToPick = int256(withinK[j]);
                        nextPath = opt_path;
                    }
                }
                if(riderToPick == -1) {
                    if(plans[i].planNode.length==0) {
                        for(uint256 t=0;t<sp.length;t++) {
                            PlanNode memory temp;
                            temp.nodeId = sp[t];
                            temp.riderId = -1;
                            temp.visited = 0;
                            plans[i].planNode.push(temp);
                        }
                    }
                    for(uint256 t=0;t<plans[i].planNode.length;t++) {
                        if(plans[i].planNode[t].visited==0) {
                            covered_till+=graph[current][plans[i].planNode[t].nodeId];
                            current = plans[i].planNode[t].nodeId;
                            plans[i].planNode[t].visited = 1;
                            break;
                        }
                    }
                    continue;
                }
                assigned[uint256(riderToPick)] = 1;
                plans[i].allRiders.push(uint256(riderToPick));
                delete newplan;
                if(plans[i].planNode.length>0) {
                    uint256 t = 0;
                    while(plans[i].planNode[t].visited==1) {
                        newplan.push(plans[i].planNode[t]);
                        t = t+1;
                    }
                }
                endConsidered = new uint256[](r);
                uint256 startConsidered = 0;
                for(uint256 p=0;p<plans[i].allRiders.length;p++) {
                    endConsidered[plans[i].allRiders[p]] = 0;    
                }
                for(uint256 t=0;t<nextPath.length;t++) {
                    PlanNode memory temp;
                    temp.nodeId = nextPath[t];
                    temp.riderId = -1;
                    if(riders[uint256(riderToPick)].start==opt_path[t] && startConsidered==0) {
                        temp.riderId = riderToPick;
                        startConsidered = 1;
                        temp.pick = 1;
                    }
                    else temp.riderId = -1;
                    for(uint256 p=0;p<plans[i].allRiders.length;p++) {
                        if(opt_path[t]==riders[plans[i].allRiders[p]].end && endConsidered[plans[i].allRiders[p]]==0) {
                            temp.riderId = int256(plans[i].allRiders[p]);
                            endConsidered[plans[i].allRiders[p]] = 1;
                            temp.pick = 0;
                        }
                    }
                    temp.visited = 0;
                    newplan.push(temp);
                }
                for(uint256 t=0;t<newplan.length;t++) {
                    if(newplan[t].visited==1) continue;
                    else {
                        covered_till+=graph[current][newplan[t].nodeId];
                        newplan[t].visited = 1;
                        current = newplan[t].nodeId;
                        if(newplan[t].nodeId == riders[uint256(riderToPick)].start) break;
                    }
                }
                uint256 tempC = drivers[i].start;
                spl = 0;
                for(uint256 t=0;t<newplan.length;t++) {
                    spl+=graph[tempC][newplan[t].nodeId];
                    tempC = newplan[t].nodeId;
                }
                plans[i].planNode = newplan;
                k = (spl-minDis);
                drivers[i].seats = drivers[i].seats - 1;
            }
        }
    }
    
    function retrievedriverplan() public view returns (Plans[] memory){
        return plans;
    }
}
