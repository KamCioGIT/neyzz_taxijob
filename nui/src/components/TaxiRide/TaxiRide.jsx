import React from "react";

export default function TaxiRide({id, name, location, destination, distance, ...comps}) {

    return (
        <div className="taxiRide" style={{color: 'white'}}>
            <h3>Course n°{id}</h3>
            <p>{name}</p>
            <p>{location}</p>
            <p>{destination}</p>
            <p>{distance}</p>
        </div>
    )
}