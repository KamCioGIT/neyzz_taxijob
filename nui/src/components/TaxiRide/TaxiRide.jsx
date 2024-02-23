import React from "react";
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import { faPerson, faLocation, faMapLocationDot, faRoute } from '@fortawesome/free-solid-svg-icons';
import Button from "../Button/Button.jsx";
import { VisibilityProvider, useVisibility } from "../../providers/VisibilityProvider.jsx";
import './TaxiRide.css'

export default function TaxiRide({id, name, location, destination, distance, ...comps}) {
    const handleClick = (rideId, setVisible) => {
        setVisible(false)
    }
    const visible = useVisibility();
    // setVisible(false)
    return (
        <div className="taxiRide" style={{color: 'white'}}>
            <h3>Course n°{id}</h3>
            <p><FontAwesomeIcon icon={faPerson} className ="personName"/> {name}</p>
            <p><FontAwesomeIcon icon={faLocation} /> {location}</p>
            <p><FontAwesomeIcon icon={faMapLocationDot} /> {destination}</p>
            <p><FontAwesomeIcon icon={faRoute} /> {distance}m</p>
            <Button text = "Accepter" type="success"/>
        </div> 
    )
}