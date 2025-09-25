import React, { useEffect, useState } from 'react';

interface Route {
  id: number;
  routeName: string;
}

const RouteList: React.FC = () => {
  const [routes, setRoutes] = useState<Route[]>([]);

  useEffect(() => {
    fetch('http://localhost:8080/route', { headers: { accept: '*/*' } })
      .then(res => res.json())
      .then(data => setRoutes(data))
      .catch(error => console.error('Error fetching routes:', error));
  }, []);

  return (
    <div>
      <h1>Route Details</h1>
      <ul>
        {routes.map(route => (
          <li key={route.id}>
            {route.id} - {route.routeName}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default RouteList;
