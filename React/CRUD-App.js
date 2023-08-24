import React, { useState, useEffect } from "react";

function App() {
 const [data, setData] = useState([]);
 const [search, setSearch] = useState("");
 const [loading, setLoading] = useState(false);
 const [error, setError] = useState(null);

 const dbConfig = {
   host: "localhost",
   user: "root",
   password: "password",
   database: "radius",
   port: 3306
 };

 const connectionDetails = `Host: ${dbConfig.host}, User: ${dbConfig.user}, Database: ${dbConfig.database}`;

 useEffect(() => {
   setLoading(true);
   fetch(`/api/radcheck?host=${dbConfig.host}&user=${dbConfig.user}&password=${dbConfig.password}&database=${dbConfig.database}&port=${dbConfig.port}`)
     .then((response) => response.json())
     .then((data) => setData(data))
     .catch((error) => setError(error))
     .finally(() => setLoading(false));
 }, []);

 const handleSearchChange = (event) => {
   setSearch(event.target.value);
 };

 const filteredData = data.filter((row) =>
   row.username.toLowerCase().includes(search.toLowerCase())
 );

 if (loading) {
   return <div>Loading...</div>;
 }

 if (error) {
   return <div>Error: {error.message}</div>;
 }

 return (
<div>
<h1>Data from Radcheck Table</h1>
<p>{connectionDetails}</p>
<input
       type="text"
       placeholder="Search by username"
       value={search}
       onChange={handleSearchChange}
     />
<table>
<thead>
<tr>
<th>Username</th>
<th>Attribute</th>
<th>Value</th>
</tr>
</thead>
<tbody>
         {filteredData.map((row) => (
<tr key={row.id}>
<td>{row.username}</td>
<td>{row.attribute}</td>
<td>{row.value}</td>
</tr>
         ))}
</tbody>
</table>
</div>
 );
}

export default App;
