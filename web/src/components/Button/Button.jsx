import React from "react";

import './Button.css'

export default function Button({...props}) {
    const btnType = props.type == "success" ? "success":
    props.type == "error" ? "error" : "default"
    return (
        <button className={"btn " + btnType}>{props.text}</button>
    )
}