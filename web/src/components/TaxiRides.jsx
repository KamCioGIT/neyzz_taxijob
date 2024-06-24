import React, { useEffect, useState } from "react";
import TaxiRide from "./TaxiRide/TaxiRide";
import { fetchNui } from "../utils/fetchNui.js";
import { useNuiEvent } from "../hooks/useNuiEvent.js";

export default function TaxiRides() {

    const [rides, setRides] = useState([]);
    useNuiEvent('newCourse', (courses) => {
        setRides(courses)
    })
    useEffect(() => {
        fetchNui('fetchCourses', "", [
            { id: 12, name: "John Doe", roadName: "Joshua Road", destination: "Vespucci", distance: 140.5 },
            { id: 13, name:"John Doe", roadName:"Joshua Road", destination: "Vespucci", distance: 140.5},
            { id: 14, name:"John Doe", roadName:"Joshua Road", destination: "Vespucci", distance: 140.5},
            { id: 15, name:"John Doe", roadName:"Joshua Road", destination: "Vespucci", distance: 140.5},
            { id: 16, name:"John Doe", roadName:"Joshua Road", destination: "Vespucci", distance: 140.5},
            { id: 17, name:"John Doe", roadName:"Joshua Road", destination: "Vespucci", distance: 140.5},
            { id: 18, name: "John Doe", roadName: "Joshua Road", destination: "Vespucci", distance: 140.5 },
        ]).then(data => {
            setRides(data)
        }).catch(err => {
            console.log('Failed to fetch')
        })
    }, [])

    const SelectRide = (id) =>{
        console.log('test')
        fetchNui('acceptRide', {id: id}).then(data => {
            console.log('Accepted Ride')
        }).catch(err => {
            console.log('Failed to fetch')
        })
    }

    const rds = rides.map(ride => (
        <TaxiRide id={ride.id} name={ride.name} location={ride.roadName} destination={ride.destination} distance={Math.round(ride.distance)} key={ride.id} Select={SelectRide} taxiId={ride.taxi} selfId={ride.selfId}/>
    ))

    return (<div className="taxiRides">
        {rds}
    </div>)
}